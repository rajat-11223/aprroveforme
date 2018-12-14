class Approver < ApplicationRecord
  belongs_to :approval, inverse_of: :approvers, autosave: true
  before_save { |approver| approver.email = approver.email.downcase }

  include ActionView::Helpers::DateHelper
  include CreationDateScopes

  validates_presence_of :name
  validates_presence_of :email

  validates :status, inclusion: {in: %w(approved declined)}, if: :has_responded?
  validates :status, inclusion: {in: %w(pending approved declined)}

  validates :required, inclusion: {in: %w(required optional)}
  validates_format_of :email, :with => /\A(.*)@(.*)\.(.*)\Z/

  def to_s
    "Your approval is #{self.required}. #{self.approval.deadline_in_words}".humanize
  end

  def generate_code
    self.code = SecureRandom.alphanumeric(50)
  end

  scope :for_email, -> (*emails) { where(email: Array(emails).compact.map(&:downcase)) }
  scope :by_user, -> (user) { for_email(user.email) }

  scope :required, -> { where(required: "required") }
  scope :optional, -> { where(required: "optional") }

  scope :approved, -> { where(status: "approved") }
  scope :declined, -> { where(status: "declined") }
  scope :pending, -> { where(status: "pending") }
  scope :approved_or_declined, -> { approved.or(Approver.declined) }

  scope :responded, -> { where("responded_at <= ?", Time.zone.now) }
  scope :not_responded, -> { where("responded_at > ?", Time.zone.now).or(Approver.where(responded_at: nil)) }

  def has_responded?
    self.responded_at? &&
      self.responded_at <= Time.zone.now
  end

  def declined?
    status == "declined"
  end

  def approved?
    status == "approved"
  end

  def pending?
    status == "pending"
  end
end
