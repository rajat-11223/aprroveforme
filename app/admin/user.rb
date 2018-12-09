ActiveAdmin.register User do
  menu priority: 2

  actions :all, :except => [:new, :edit, :create]

  index do
    id_column
    column(:email)
    column(:first_name)
    column(:last_name)
    column(:approvals_sent)
    column(:approvals_received)
    column(:picture) { |u| image_tag(u.picture, width: "50px") }
    column(:created_at)
    actions
  end
end
