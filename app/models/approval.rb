# frozen_string_literal: true

class Approval < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include CreationDateScopes

  has_many :approvers, dependent: :destroy, inverse_of: :approval, autosave: true
  has_many :tasks, dependent: :destroy

  validates :title, presence: true
  validates :deadline, presence: true

  validate :deadline_in_future, on: :create
  validate :require_one_approver
  validate :require_link

  scope :deadline_is_in_future, -> { where("deadline >= ?", 1.day.from_now.beginning_of_day) }
  scope :deadline_is_past, -> { where("deadline < ?", 1.day.from_now.beginning_of_day) }

  belongs_to :user, foreign_key: :owner

  accepts_nested_attributes_for :approvers,
                                reject_if: proc { |attributes| attributes["name"].blank? || attributes["email"].blank? },
                                allow_destroy: true

  def request_type
    @request_type ||= RequestType.approval
  end

  def deadline_in_words
    to_append = past_due? ? " ago" : " remaining"
    distance_of_time_in_words_to_now(self.deadline).humanize + to_append
  end

  def past_due?
    Time.now > self.deadline
  end

  # TODO: review whether required is cap
  def percentage_complete
    percent =
      if required_approver_count > 0
        (required_approved_count / required_approver_count) * 100
      else
        0
      end
    "#{percent}%"
  end

  def ratio_complete
    "#{required_approved_count}/#{required_approver_count}"
  end

  def complete?
    all_required_responses? || past_due?
  end

  def all_required_responses?
    required_approver_count == required_approved_count
  end

  private

  def required_approver_count
    approvers.required.count
  end

  def required_approved_count
    approvers.approved.required.count
  end

  def require_one_approver
    return unless approvers.empty?

    errors.add(:approvers, "You must include at least one approver. For each approver, please provide a name and email address so that we can contact them.")
  end

  def require_link
    return if link.present?

    errors.add(:link, "Please select a file or upload a new one.")
  end

  def deadline_in_future
    return if deadline.present? && deadline.beginning_of_day >= Time.zone.today.end_of_day

    errors.add(:deadline, "Please select a deadline in the future")
  end
end
