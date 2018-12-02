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
      approver = @approval.approvers.find { |a| a.code == session[:code] }

      if approver.present? && (approver.approval_id == @approval.id) and (current_user.email != approver.email)
        current_user.update_attributes second_email: approver.email.downcase
      end

      session.delete(:code)
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
  end

  # GET /approvals/1/edit
  def edit
    @approval = Approval.find(params[:id])
    authorize! :edit, @approval
  end

  # POST /approvals
  # POST /approvals.json
  def create
    @approval = Approval.new(approval_params.merge(owner: current_user.id))
    authorize! :create, @approval

    @approval.deadline = parse_deadline

    google_drive_file_id = @approval.link_id

    @approval.valid?

    user_permission_updates =
      @approval.approvers.map do |approver|
        approver.generate_code
        approver.save

        Google::Drive::File::AddUserRole.new(google_drive_file_id, user: current_user,
                                                                   approver: approver,
                                                                   role: google_drive_permission) unless make_public?
      end

    make_file_public = Google::Drive::File::MakePublic.new(google_drive_file_id, user: current_user,
                                                                                 role: google_drive_permission)
    resp = apply_permission_updates!(user_permission_updates, make_file_public: make_file_public)

    if @approval.errors.none? && @approval.save
      ab_finished(:approval_created)

      UserMailer.my_new_approval(@approval).deliver_later
      @approval.approvers.each { |approver| UserMailer.new_approval_invite(@approval, approver).deliver_later }

      redirect_to @approval, notice: ["Approval was successfully created.", resp[:warning]].compact.join(" ")
    else
      flash[:notice] = ["Approval was not created.", resp[:warning]].compact.join(" ")
      render action: "new"
    end
  end

  # PUT /approvals/1
  # PUT /approvals/1.json
  def update
    @approval = Approval.includes(:approvers).find(params[:id])

    authorize! :update, @approval

    if @approval.update_attributes(approval_params.merge(deadline: parse_deadline))
      google_drive_file_id = @approval.link_id

      # if any new approvers, add permissions and code
      approvers_without_codes = @approval.approvers.select { |a| !a.code.present? }
      user_permission_updates =
        approvers_without_codes.map do |approver|
          approver.generate_code
          approver.save

          UserMailer.new_approval_invite(@approval, approver).deliver_later

          Google::Drive::File::AddUserRole.new(google_drive_file_id, user: current_user,
                                                                     approver: approver,
                                                                     role: google_drive_permission) unless make_public?
        end

      @approval.save

      make_file_public = Google::Drive::File::MakePublic.new(google_drive_file_id, user: current_user, role: google_drive_permission)
      resp = apply_permission_updates!(user_permission_updates, make_file_public: make_file_public)

      redirect_to @approval, notice: ["Approval was successfully updated.", resp[:warning]].compact.join(" ")
    else
      render action: "edit"
    end
  end

  # DELETE /approvals/1
  # DELETE /approvals/1.json
  def destroy
    @approval = Approval.find(params[:id])
    authorize! :destroy, @approval

    @approval.destroy
    redirect_to root_url, notice: "Approval was successfully deleted."
  end

  private

  def prefill_from_template(approval)
    return unless params[:from_approval] && from_approval = current_user.approvals.find(params[:from_approval])

    flash[:notice] = "New approval successfully created from '#{from_approval.title}'. Document permissions and approver details have been set."

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
    params.require(:approval).permit(:id, :deadline, :description, :link, :title, :embed, :link_title, :link_id, :link_type, :tasks_attributes, :drive_perms, :drive_public, approvers_attributes: [:_destroy, :id, :email, :name, :required, :status, :comments, :code])
  end

  def require_user_or_code!
    if params[:code] && approver = Approver.joins(:approval).where(approvals: {id: params[:id]}).find_by(code: params[:code])
      redirect_to response_path(approver, code: approver.code)
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
    permission_updates = [make_file_public] if make_public?

    begin
      permission_updates.compact.map(&:call)
    rescue Google::Drive::File::SetPermission::InvalidGoogleUser => e
      # Since we have an invalid Google user, make the file publically accessible
      make_file_public.call

      # Set approval as public, since we had to force it public.
      @approval.drive_public = true
      response[:warning] = e.message
    rescue Google::Drive::File::SetPermission::DoNotOwnDocument => e
      response[:warning] = e.message
      @approval.errors.add :link, e.message
    end

    response
  end
end
