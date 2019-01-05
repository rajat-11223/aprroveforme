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
    @approval = Approval.new(approval_params.merge(owner: current_user.id, deadline: parse_deadline))
    authorize! :create, @approval

    if @approval.valid? && @approval.save
      apply_permission_updates!(approval: @approval, file_id: @approval.link_id)

      ab_finished(:approval_created)

      UserMailer.my_new_approval(@approval).deliver_later

      redirect_to @approval, notice: "Approval was successfully created."
    else
      flash[:notice] = "Approval was not created."
      render action: "new"
    end
  end

  # PUT /approvals/1
  # PUT /approvals/1.json
  def update
    @approval = Approval.includes(:approvers).find(params[:id])

    authorize! :update, @approval

    @approval.assign_attributes(approval_params.merge(deadline: parse_deadline))

    if @approval.valid? && @approval.save
      # if any new approvers, add permissions and code
      apply_permission_updates!(approval: @approval, file_id: @approval.link_id)

      redirect_to @approval, notice: "Approval was successfully updated."
    else
      flash[:notice] = "Approval was not created."
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
    deadline_str = params.dig(:approval, :deadline)
    return unless deadline_str.present?

    deadline = Time.zone.parse(deadline_str)
    if current_user.paid?
      deadline
    else
      # Conform the time to noon for free accounts
      deadline.noon
    end
  end

  def google_drive_permission
    approval_params[:drive_perms]
  end

  def apply_permission_updates!(approval:, file_id:)
    if make_public?
      Google::Drive::File::MakePublic.new(file_id,
                                          user: current_user,
                                          role: google_drive_permission).call
    else
      approval.approvers.each do |approver|
        Google::Drive::File::AddUserRole.new(file_id,
                                             user: current_user,
                                             approver: approver,
                                             role: google_drive_permission).call
      end
    end

    approval
      .approvers
      .select { |a| a.code.blank? }
      .each(&:generate_code)
      .each(&:save!)
      .each do |approver|
      UserMailer.new_approval_invite(approval, approver).deliver_later
    end

    # begin
    # rescue Google::Drive::File::SetPermission::InvalidGoogleUser => e
    #   # Since we have an invalid Google user, make the file publically accessible
    #   make_file_public.call

    #   # Set approval as public, since we had to force it public.
    #   @approval.drive_public = true
    #   response[:warning] = e.message
    # rescue Google::Drive::File::SetPermission::DoNotOwnDocument => e
    #   response[:warning] = e.message
    #   @approval.errors.add :link, e.message
    # end
  end
end
