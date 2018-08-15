class ApprovalsController < ApplicationController
  before_action :require_user!, except: [:show]
  before_action :require_user_or_code!, only: [:show]


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

    if session[:code]
      approver = @approval.approvers.find {|a| a.code == session[:code] }

      if (approver.approval_id == @approval.id) and (current_user.email != approver.email )
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
    if !current_user.subscription.present?
      redirect_to pricing_path, notice: 'Please subscribe to a plan to continue creating approvals'
    end

    recent_approvals_count = Approval.from_this_month.for_owner(current_user.id).count

    if recent_approvals_count >= plan_responses_limit
      redirect_to pricing_path,
        notice: "Please upgrade your plan to continue creating approvals. You have used #{recent_approvals_count} of #{plan_responses_limit}"
    end

    @approval = Approval.new(perms: "reader", owner: current_user.id)
    authorize! :create, @approval

    if @approval.approvers.empty?
      3.times { @approval.approvers.build }
    end

    # if the doc is being opened from Google drive, pre-populate
    if session[:state] and (session[:state]['action'] == 'open')
      current_user.refresh_google
      api_client = current_user.google_auth
      file_id = (session[:state]['exportIds'][0])

      if file_id
        file = file_metadata(api_client, file_id)
        if file
          @approval.link_title = file.title
          @approval.embed = file.embedLink
          @approval.link_id = file.id
          @approval.link_type = file.mimeType
          @approval.link = file.alternateLink
        end
      end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @approval }
    end
  end

  def file_metadata(client, file_id)
    @drive = client.discovered_api('drive', 'v2')
    result = client.execute(
        :api_method => @drive.files.get,
        :parameters => { 'fileId' => file_id })
    if result.status == 200
      return result.data
    else
      puts "An error occurred: #{result.data['error']['message']}"
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

    deadline = params.dig(:approval, :deadline).match(/\d{2}\/\d{2}\/\d{4}/)
    deadline.present? && @approval.deadline = DateTime.strptime(deadline.to_s, "%m/%d/%Y")

    @approval.approvers.each do |approver|
      @approval.update_permissions(@approval.link_id, current_user, approver, params[:approval][:perms]) if @approval.link
      approver.generate_code
    end

    respond_to do |format|
      if @approval.save
        ab_finished(:approval_created)
        format.html { redirect_to @approval, notice: 'Approval was successfully created.' }
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
    if params.dig(:approval, :approver)
      authorize! :approve, @approval
      @approver = @approval.approvers.for_email(current_user.email, current_user.second_email).first
      @approver.update_attributes! status: params.dig(:approval, :approver, :status),
                                   comments: params.dig(:approval, :approver, :comments)

      # @approval.tasks << Task.new(params[:approval][:tasks])
      #params[:approval][:approver][:tasks].each do |task|
      #  @approver.tasks << task
      #end
      ab_finished(:approver_approved)
      UserMailer.approval_update(@approver).deliver_later

      UserMailer.completed_approval(@approval).deliver_later if @approval.complete?

      redirect_to @approval, notice: 'Approval submitted'
    else
      authorize! :update, @approval

      if params[:approval][:deadline].match(/\d{2}\/\d{2}\/\d{4}/)
        params[:approval][:deadline] = DateTime.strptime(params.dig(:approval, :deadline), "%m/%d/%Y")
      end

      respond_to do |format|
        if @approval.update_attributes(approval_params)
          # if any new approvers, add permissions and code

          approvers_without_codes = @approval.approvers.select {|a| !a.code.present? }
          approvers_without_codes.each do |approver|
            @approval.update_permissions(@approval.link_id,
                                         current_user,
                                         approver, params.dig(:approval, :perms))
            approver.generate_code
            @approval.save

            UserMailer.new_approval_invite(@approval, approver).deliver_later
          end

          format.html { redirect_to @approval, notice: 'Approval was successfully updated.' }
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

  def approval_params
    params.require(:approval).permit(:id,:deadline, :description, :link, :title, :embed, :link_title, :link_id, :link_type, :tasks_attributes, :perms, approvers_attributes: [:_destroy, :id,:email, :name, :required, :status, :comments, :code])
  end

  def plan_responses_limit
    @plan_responses_limit ||=
      case current_user.subscription.plan_type
      when 'free'
        2
      when 'professional'
        6
      when 'unlimited'
        10_000_000_000
      else
        0
      end
  end

  def require_user_or_code!
    if session[:code]
      require_user!(message: "Please sign in with Google Drive to approve this document.")
    else
      require_user!
    end
  end
end
