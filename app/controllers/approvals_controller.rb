class ApprovalsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /approvals
  # GET /approvals.json
  def index
    @approvals = Approval.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @approvals }
    end
  end

  # GET /approvals/1
  # GET /approvals/1.json
  def show
    @approval = Approval.find(params[:id])
    @user = current_user

    if params[:code]
      approver = Approver.where("code = ?", params[:code]).first
      if (approver.approval_id == @approval.id) and (@user.email != approver.email)
        @user.set_second_email(approver.email)
        @user.save
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @approval }
    end
  end

  # GET /approvals/new
  # GET /approvals/new.json
  def new
    @approval = Approval.new
    3.times {@approval.approvers.build} if @approval.approvers.empty?

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @approval }
    end
  end

  # GET /approvals/1/edit
  def edit
    @approval = Approval.find(params[:id])

  end

  # POST /approvals
  # POST /approvals.json
  def create
    @approval = Approval.new(params[:approval])
    @approval.owner = current_user.id
    if params[:approval][:deadline].match(/\d{2}\/\d{2}\/\d{4}/)
      @approval.deadline = DateTime.strptime(params[:approval][:deadline], "%m/%d/%Y")
    end

    @approval.approvers.each do |approver| 
      @approval.update_permissions(@approval.link_id, current_user, approver, params[:perms] || "reader") if @approval.link
      approver.generate_code
    end

    
    respond_to do |format|
      if @approval.save
        format.html { redirect_to @approval, notice: 'Approval was successfully created.' }
        format.json { render json: @approval, status: :created, location: @approval }
        UserMailer.delay.my_new_approval(@approval)
        UserMailer.delay.new_approval_invite(@approval)
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
    
    # if an approver is approving
    if params[:approval][:approver]
      @approver = @approval.approvers.where("email = ? or email = ?", current_user.email, current_user.second_email).first
      @approver.status = params[:approval][:approver][:status]
      @approver.comments = params[:approval][:approver][:comments]
      @approver.save
      UserMailer.delay.approval_update(@approver)
      UserMailer.delay.completed_approval(@approval) if percentage_complete(@approval) == "100%"
      redirect_to @approval, notice: 'Approval submitted'
    else
      if params[:approval][:deadline].match(/\d{2}\/\d{2}\/\d{4}/)
        params[:approval][:deadline] = DateTime.strptime(params[:approval][:deadline], "%m/%d/%Y")
      end

      

      respond_to do |format|
        if @approval.update_attributes(params[:approval])

          # if any new approvers, add permissions and code
          @approval.approvers.each do |approver| 
            if approver.code == nil
              @approval.update_permissions(@approval.link_id, current_user, approver, params[:perms] || "reader") 
              approver.generate_code
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
    @approval.destroy

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end
end


def percentage_complete(approval)
      @approver_count = approval.approvers.count
      @approved_count = approval.approvers.where("status = ?", "Approved").count

      if @approver_count > 0
        return "#{((@approved_count*100)/@approver_count)}%"
      else
        return "0%"
      end
  end
