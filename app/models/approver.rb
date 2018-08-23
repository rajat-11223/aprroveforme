class Approver < ApplicationRecord
  belongs_to :approval, inverse_of: :approvers
  before_save { |approver| approver.email = approver.email.downcase }

  include ActionView::Helpers::DateHelper
  include CreationDateScopes

  def to_s
    string = "Your approval is #{self.required}. ".humanize
    string << self.approval.deadline_in_words
  end

  def generate_code
    self.code = SecureRandom.alphanumeric(50)
  end

  scope :for_email, -> (email_one, email_two) do
    emails = [email_one, email_two].compact.map(&:downcase)
    case emails.length
    when 0
      scoped
    when 1
      where(email: emails[0].downcase)
    when 2
      where(email: emails[0]).or(Approver.where(email: emails[1]))
    end
  end

  scope :by_user, -> (user) { for_email(user.email, user.second_email) }

  scope :required, -> { where(required: "Required") }
  scope :optional, -> { where(required: "Optional") }

  scope :approved, -> { where(status: "Approved") }
  scope :declined, -> { where(status: "Declined") }
  scope :pending, -> { where(status: "").or(Approver.where(status: "Pending")) }
  scope :approved_or_declined, -> { approved.or(Approver.declined) }

  def has_responded?
    ["Approved", "Declined"].include? self.status
  end
end
