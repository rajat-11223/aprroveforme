class ApprovalsController < ApplicationController
  before_action :require_user!, except: [:show]
  before_action :require_user_or_code!, only: [:show]

  before_action :require_subscription
  before_action :require_remaining_approvals_in_plan, only: [:new, :create]

  # GET /approvals
  # GET /approvals.json
  def index
    authorize! :manage, :all
    @approvals = Approval.all
  end

  # GET /approvals/1
  # GET /approvals/1.json
  def show
    @approval = Approval.includes(:approvers).find(params[:id])
    authorize! :read, @approval

    # 3.times { @approval.tasks.build } if @approval.tasks.empty?

    if session[:code].present?
      approver = @approval.approvers.find {|a| a.code == session[:code] }

      if approver.present? && (approver.approval_id == @approval.id) and (current_user.email != approver.email )
        current_user.update_attributes second_email: approver.email.downcase
      end

      session.delete(:code)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @approval }
    end
  end

  # GET /approvals/new
  # GET /approvals/new.json
  def new
    @approval = Approval.new(drive_perms: "reader", owner: current_user.id)

    authorize! :create, @approval
    prefill_from_template(@approval)

    if @approval.approvers.empty?
      3.times { @approval.approvers.build }
    end

    # if the doc is being opened from Google drive, pre-populate
    Google::PrepopulateApprovalFromDrive.new(session, @approval, current_user).call

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @approval }
    end
  end

  # GET /approvals/1/edit
  def edit
    @approval = Approval.find(params[:id])
    authorize! :edit, @approval
  end

  # POST /approvals
  # POST /approvals.json
  def create
    @approval = Approval.new(approval_params)
    @approval.owner = current_user.id
    authorize! :create, @approval

    @approval.deadline = parse_deadline

    google_drive_file_id = @approval.link_id

    user_permission_updates =
      @approval.approvers.map do |approver|
        approver.generate_code
        approver.save

        if google_drive_file_id.present? && !make_public?
          Google::Drive::File::AddUserRole.new(google_drive_file_id, user: current_user, approver: approver, role: google_drive_permission)
        else
          nil
        end
      end

    success_notice = "Approval was successfully created."
    make_file_public = Google::Drive::File::MakePublic.new(google_drive_file_id, user: current_user, role: google_drive_permission)
    resp = apply_permission_updates!(user_permission_updates, make_file_public: make_file_public)

    success_notice << " #{resp[:warning]}" if resp[:warning]

    respond_to do |format|
      if @approval.save
        ab_finished(:approval_created)
        format.html { redirect_to @approval, notice: success_notice }
        format.json { render json: @approval, status: :created, location: @approval }
        UserMailer.my_new_approval(@approval).deliver_later

        @approval.approvers.each do |approver|
          UserMailer.new_approval_invite(@approval, approver).deliver_later
        end
      else
        format.html { render action: "new" }
        format.json { render json: @approval.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /approvals/1
  # PUT /approvals/1.json
  def update
    @approval = Approval.includes(:approvers).find(params[:id])

    # if an approver is approving
    # TODO: Move this to another route
    if params.dig(:approval, :approver)
      authorize! :approve, @approval
      @approver = @approval.approvers.by_user(current_user).first
      @approver.update_attributes! status: params.dig(:approval, :approver, :status),
                                   comments: params.dig(:approval, :approver, :comments)

      ab_finished(:approver_approved)
      UserMailer.approval_update(@approver).deliver_later

      UserMailer.completed_approval(@approval).deliver_later if @approval.complete?

      redirect_to @approval, notice: "Approval submitted"
    else
      authorize! :update, @approval

      respond_to do |format|
        if @approval.update_attributes(approval_params.merge(deadline: parse_deadline))
          google_drive_file_id = @approval.link_id

          # if any new approvers, add permissions and code
          approvers_without_codes = @approval.approvers.select {|a| !a.code.present? }
          user_permission_updates =
            approvers_without_codes.map do |approver|
              approver.generate_code
              approver.save

              UserMailer.new_approval_invite(@approval, approver).deliver_later

              if google_drive_file_id.present? && !make_public?
                Google::Drive::File::AddUserRole.new(google_drive_file_id, user: current_user, approver: approver, role: google_drive_permission)
              else
                nil
              end
            end

          @approval.save

          success_notice = "Approval was successfully updated."
          make_file_public = Google::Drive::File::MakePublic.new(google_drive_file_id, user: current_user, role: google_drive_permission)
          resp = apply_permission_updates!(user_permission_updates, make_file_public: make_file_public)

          success_notice << " #{resp[:warning]}" if resp[:warning]

          format.html { redirect_to @approval, notice: success_notice }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @approval.errors, status: :unprocessable_entity }
        end
      end

    end
  end

  # DELETE /approvals/1
  # DELETE /approvals/1.json
  def destroy
    @approval = Approval.find(params[:id])
    authorize! :destroy, @approval

    @approval.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: "Approval was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private

  def prefill_from_template(approval)
    return unless params[:from_approval] && from_approval = current_user.approvals.find(params[:from_approval])

    deadline_distance = from_approval.deadline - from_approval.created_at
    deadline = (Time.now + deadline_distance).end_of_day

    template_attrs = from_approval.
                       attributes.
                       slice("drive_perms", "drive_public").
                       merge(deadline: deadline)

    approval.assign_attributes(template_attrs)

    from_approval.approvers.each do |from_approver|
      approval.approvers.build name: from_approver.name,
                               email: from_approver.email,
                               required: from_approver.required
    end
  end

  def approval_params
    params.require(:approval).permit(:id, :deadline, :description, :link, :title, :embed, :link_title, :link_id, :link_type, :tasks_attributes, :drive_perms, :drive_public, approvers_attributes: [:_destroy, :id,:email, :name, :required, :status, :comments, :code])
  end

  def require_user_or_code!
    if session[:code]
      require_user!(message: "Please sign in with Google Drive to approve this document.")
    else
      require_user!
    end
  end

  def make_public?
    approval_params[:drive_public] == "true"
  end

  def parse_deadline
    deadline = params.dig(:approval, :deadline).match(/\d{2}\/\d{2}\/\d{4}/).to_s
    deadline.presence && DateTime.strptime(deadline, "%m/%d/%Y")
  end

  def google_drive_permission
    approval_params[:drive_perms]
  end

  def apply_permission_updates!(permission_updates, make_file_public:)
    response = {}
    permission_updates = permission_updates.dup
    permission_updates = [ make_file_public ] if make_public?

    begin
      permission_updates.compact.map(&:call)
    rescue Google::Drive::File::SetPermission::InvalidGoogleUser => e
      # Since we have an invalid Google user, make the file publically accessible
      make_file_public.call
      response[:warning] = e.message
    end

    response
  end
end
