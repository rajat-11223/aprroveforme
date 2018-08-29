class Approver < ApplicationRecord
  belongs_to :approval, inverse_of: :approvers, autosave: true
  before_save { |approver| approver.email = approver.email.downcase }

  include ActionView::Helpers::DateHelper
  include CreationDateScopes

  validates_presence_of :name
  validates_presence_of :email
  validates :status, inclusion: { in: %w(pending approved declined) }
  validates :required, inclusion: { in: %w(required optional) }

  def to_s
    "Your approval is #{self.required}. #{self.approval.deadline_in_words}".humanize
  end

  def generate_code
    self.code = SecureRandom.alphanumeric(50)
  end

  scope :for_email, -> (*emails) { where(email: Array(emails).compact.map(&:downcase)) }
  scope :by_user, -> (user) { for_email(*user.all_emails) }

  scope :required, -> { where(required: "required") }
  scope :optional, -> { where(required: "optional") }

  scope :approved, -> { where(status: "approved") }
  scope :declined, -> { where(status: "declined") }
  scope :pending, -> { where(status: "pending") }
  scope :approved_or_declined, -> { approved.or(Approver.declined) }

  def has_responded?
    ["approved", "declined"].include? self.status
  end
end
