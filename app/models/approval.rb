# frozen_string_literal: true

# == Schema Information
#
# Table name: approvals
#
#  id              :integer          not null, primary key
#  completed_at    :datetime
#  deadline        :datetime         not null
#  description     :text             default(""), not null
#  drive_perms     :string(255)      default("reader")
#  drive_public    :boolean          default(TRUE), not null
#  embed           :string(255)
#  link            :string(255)
#  link_title      :string(255)
#  link_type       :string(255)
#  owner           :integer          not null
#  title           :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  link_id         :string(255)
#  request_type_id :bigint(8)
#
# Indexes
#
#  index_approvals_on_completed_at     (completed_at)
#  index_approvals_on_request_type_id  (request_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (request_type_id => request_types.id)
#

class Approval < ApplicationRecord
  include ActionView::Helpers::DateHelper
  include CreationDateScopes

  has_many :approvers, dependent: :destroy, inverse_of: :approval, autosave: true
  has_many :tasks, dependent: :destroy

  validates :title, presence: true, length: {maximum: 150}
  validates :deadline, presence: true

  validate :deadline_in_future, on: :create
  validate :require_one_approver
  validate :require_link

  default_scope -> { order(created_at: :desc) }

  scope :deadline_is_in_future, -> { where("deadline >= ?", 1.day.from_now.beginning_of_day) }
  scope :deadline_is_past, -> { where("deadline < ?", 1.day.from_now.beginning_of_day) }

  scope :complete, -> { where("completed_at <= ?", Time.zone.now) }
  scope :not_complete, -> { where("completed_at > ?", Time.zone.now).or(Approval.where(completed_at: nil)) }

  belongs_to :user, foreign_key: :owner

  accepts_nested_attributes_for :approvers,
                                reject_if: proc { |attributes| attributes["name"].blank? || attributes["email"].blank? },
                                allow_destroy: true

  def complete?
    self.completed_at? && self.completed_at < Time.zone.now
  end

  def request_type
    @request_type ||= RequestType.find_by(slug: "approve")
  end

  def response_status_text
    # TODO: Base this on request type details
    if complete?
      if approvers.any?(&:declined?) || approvers.any?(&:pending?)
        "declined"
      else
        "approved"
      end
    else
      "pending"
    end
  end

  def deadline_in_words
    to_append = past_due? ? " ago" : " remaining"
    distance_of_time_in_words_to_now(self.deadline).humanize + to_append
  end

  def completed_at_in_words
    if complete?
      to_append = past_due? ? " ago" : " remaining"
      distance_of_time_in_words_to_now(self.completed_at).humanize + to_append
    else
      "not complete yet"
    end
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

  def is_completable?
    all_required_responses? || past_due?
  end

  def all_required_responses?
    required_approver_count == required_approved_count
  end

  def mark_as_complete!
    self.update_attribute(:completed_at, Time.zone.now)
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
