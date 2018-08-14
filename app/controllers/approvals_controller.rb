class ApprovalsController < ApplicationController
  # GET /approvals
  # GET /approvals.json
  def index
    authorize! :manage, :all
    @approvals = Approval.all
  end

  # GET /approvals/1
  # GET /approvals/1.json
  def show
    @approval = Approval.find(params[:id])
    authorize! :read, @approval
    @user = current_user
    3.times { @approval.tasks.build } if @approval.tasks.empty?

    if session[:code]
      approver = Approver.where("code = ?", session[:code]).first

      if (approver.approval_id == @approval.id) and (@user.email != approver.email )
        current_user.update_attributes second_email: approver.email.downcase
      end

      session.delete(:code)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @approval }
    end
  end

  def plan_responses_limit
    if current_user.subscription.plan_type == 'free'
      2
    else current_user.subscription.plan_type == 'professional'
      6
    end
  end

  # GET /approvals/new
  # GET /approvals/new.json
  def new
    if !current_user.subscription.present?
      redirect_to pricing_index_path, notice: 'Please Subscribe a plan to continue creating Approvals'
    end

    if current_user.subscription.plan_type != 'unlimited'
      user_subscription_date = current_user.subscription.plan_date
      user_approvals = Approval.where(:owner => current_user.id, :created_at => user_subscription_date..(user_subscription_date + 30.days))

      if user_approvals.count > plan_responses_limit
        redirect_to pricing_index_path, notice: 'Please Upgrage Your plan to continue creating Approvals'
      end
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
  end

  # POST /approvals
  # POST /approvals.json
  def create
    @approval = Approval.new(approval_params)
    @approval.owner = current_user.id

    deadline = params.dig(:approval, :deadline).match(/\d{2}\/\d{2}\/\d{4}/)
    deadline.present? && @approval.deadline = DateTime.strptime(deadline.to_s, "%m/%d/%Y")

    current_ability.can? :create, @approval
    authorize! :create, @approval
    @approval.approvers.each do |approver|
      @approval.update_permissions(@approval.link_id, current_user, approver, params[:approval][:perms]) if @approval.link
      # approver.generate_code
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
    @approval = Approval.find(params[:id])
    autorize! :update, @approval

    # if an approver is approving
    if params.dig(:approval, :approver)
      @approver = @approval.approvers.where("email = ? or email= ?", current_user.email, current_user.second_email).first
      @approver.status = params.dig(:approval, :approver, :status)
      @approver.comments = params.dig(:approval, :approver, :comments)
      @approval.tasks << Task.new(params[:approval][:tasks])
      #params[:approval][:approver][:tasks].each do |task|
      #  @approver.tasks << task
      #end
      @approver.save
      ab_finished(:approver_approved)
      UserMailer.approval_update(@approver).deliver_later
      UserMailer.completed_approval(@approval).deliver_later if percentage_complete(@approval) == "100%"
      redirect_to @approval, notice: 'Approval submitted'
    else
      if params[:approval][:deadline].match(/\d{2}\/\d{2}\/\d{4}/)
        params[:approval][:deadline] = DateTime.strptime(params[:approval][:deadline], "%m/%d/%Y")
      end

      respond_to do |format|
        if @approval.update_attributes(approval_params)
          # if any new approvers, add permissions and code

          @approval.approvers.each do |approver|
            if approver.code == nil
              @approval.update_permissions(@approval.link_id, current_user, approver, params[:approval][:perms])
              # approver.generate_code0
              UserMailer.new_approval_invite(@approval, approver).deliver_later
            end
          end

          @approval.save
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
end


def percentage_complete(approval)
  @approver_count = approval.approvers.where("required = ?", "required").count
  @approved_count = approval.approvers.where("(status = ?) and (required = ?)", "Approved", "required").count

  if @approver_count > 0
    return "#{((@approved_count*100)/@approver_count)}%"
  else
    return "0%"
  end
end
