ActiveAdmin.register RequestType do
  menu priority: 4

  permit_params :name, :slug, :affirming_text, :dissenting_text, :allow_dissenting, :public, :initial_subject, :initial_body, :reminder_subject, :reminder_body, :due_soon_subject, :due_soon_body, :due_now_subject, :due_now_body, :confirmation_responder_subject, :confirmation_responder_body, :completed_request_subject, :completed_request_body

  index do
    id_column
    column(:name)
    column(:slug)
    column(:public)
    actions
  end

  scope :all, default: true
  scope :shared
  scope :not_shared

  form do |f|
    f.inputs do
      f.input :name
      f.input :slug
      f.input :public
      f.input :affirming_text
      f.input :dissenting_text
      f.input :allow_dissenting

      f.input :initial_subject, as: :string
      f.input :initial_body, as: :text
      f.input :reminder_subject, as: :string
      f.input :reminder_body, as: :text
      f.input :due_soon_subject, as: :string
      f.input :due_soon_body, as: :text
      f.input :due_now_subject, as: :string
      f.input :due_now_body, as: :text
      f.input :confirmation_responder_subject, as: :string
      f.input :confirmation_responder_body, as: :text
      f.input :completed_request_subject, as: :string
      f.input :completed_request_body, as: :text
    end
    f.actions
  end
end
