class Approver < ApplicationRecord
  belongs_to :approval, inverse_of: :approvers
  before_save { |approver| approver.email = approver.email.downcase }

  include ActionView::Helpers::DateHelper

  def to_s
    string = "Your approval is #{self.required}. ".humanize
    string << self.approval.deadline_in_words
  end

  after_initialize do
    self.code = SecureRandom.alphanumeric(50)
  end

  def generate_code
    ActiveSupport::Deprecation.warn "No longer need to #generate_code, done on initialization"
  end
end
