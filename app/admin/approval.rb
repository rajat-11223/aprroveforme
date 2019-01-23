ActiveAdmin.register Approval do
  menu priority: 3

  actions :all, :except => [:edit, :destroy]

  scope :all, default: true
  scope :complete
  scope :not_complete

  index do
    id_column
    column(:title)
    column(:description)
    column(:responder_count) { |a| a.approvers.count }
    column(:user)
    column(:link_type)
    column(:drive_perms)
    column(:deadline)
    column(:created_at)
    column(:updated_at)
    column(:complete?)
    actions
  end

  show do
    attributes_table do
      row(:title)
      row(:description)
      row(:responder_count) { |a| a.approvers.count }
      row(:user)
      row(:link_type)
      row(:drive_perms)
      row(:deadline)

      row(:created_at)
      row(:updated_at)
      row(:completed_at)
    end
    active_admin_comments
  end
end
