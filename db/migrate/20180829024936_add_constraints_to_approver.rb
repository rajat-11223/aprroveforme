class AddConstraintsToApprover < ActiveRecord::Migration[5.2]
  def change
    Approver.find_each do |approver|
      approver.email = approver.email.downcase
      approver.status = (approver.status.presence || "pending").downcase
      approver.required = (approver.required.presence || "required").downcase
      approver.comments ||= ""

      raise "INVALID #{approver.id}" unless approver.valid?
      approver.save!
    end

    change_column :approvers, :email, :string, null: false
    change_column :approvers, :name, :string, null: false
    change_column :approvers, :required, :string, null: false, default: "required"
    change_column :approvers, :status, :string, null: false, default: "pending"
    change_column :approvers, :approval_id, :integer, null: false
    change_column :approvers, :comments, :text, null: false, default: ""
  end
end
