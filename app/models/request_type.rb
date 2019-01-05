# == Schema Information
#
# Table name: request_types
#
#  id               :bigint(8)        not null, primary key
#  affirming_text   :string           not null
#  allow_dissenting :boolean          default(TRUE), not null
#  dissenting_text  :string           not null
#  email_templates  :jsonb
#  name             :string           not null
#  public           :boolean          default(FALSE), not null
#  require_comments :boolean          default(TRUE), not null
#  slug             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_request_types_on_slug  (slug)
#

class RequestType < ApplicationRecord
  before_save :strip_text_on_fields

  jsonb_accessor :email_templates,
                 initial_subject: :string,
                 initial_body: :string,
                 reminder_subject: :string,
                 reminder_body: :string,
                 due_soon_subject: :string,
                 due_soon_body: :string,
                 due_now_subject: :string,
                 due_now_body: :string,
                 confirmation_responder_subject: :string,
                 confirmation_responder_body: :string,
                 completed_request_subject: :string,
                 completed_request_body: :string

  validates :name, presence: :true, uniqueness: true
  validates :slug, presence: :true, uniqueness: true

  validates :affirming_text, presence: :true
  validates :dissenting_text, presence: :true

  # Email templates
  # validates :initial_subject, presence: true
  # validates :initial_body, presence: true
  # validates :reminder_subject, presence: true
  # validates :reminder_body, presence: true
  # validates :due_soon_subject, presence: true
  # validates :due_soon_body, presence: true
  # validates :due_now_subject, presence: true
  # validates :due_now_body, presence: true
  # validates :confirmation_responder_subject, presence: true
  # validates :confirmation_responder_body, presence: true
  # validates :completed_request_subject, presence: true
  # validates :completed_request_body, presence: true

  scope :shared, -> { where(public: true) }
  scope :not_shared, -> { where(public: false) }

  def request_options
    @request_options ||= begin
      opts = []

      opts << ["approved", affirming_text]
      opts << ["declined", dissenting_text] if allow_dissenting?

      opts
    end
  end

  def request_text_options
    request_options.map(&:last)
  end

  def lower_name
    name.downcase
  end

  def strip_text_on_fields
    [:initial_subject,
     :initial_body,
     :reminder_subject,
     :reminder_body,
     :due_soon_subject,
     :due_soon_body,
     :due_now_subject,
     :due_now_body,
     :confirmation_responder_subject,
     :confirmation_responder_body,
     :completed_request_subject,
     :completed_request_body].each do |field|
      val = self.send("#{field}")
      self.send("#{field}=", val.split("\n").map(&:strip).join("\n"))
    end
  end
end
