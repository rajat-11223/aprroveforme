 class Approval < ApplicationRecord
  include ActionView::Helpers::DateHelper

  belongs_to :user, foreign_key: "owner"
  has_many :approvers, dependent: :destroy, inverse_of: :approval
  has_many :tasks, dependent: :destroy

  validates :title, presence: true
  validates :deadline, presence: true
  # validates :deadline, format: { with: /\d{2}\/\d{2}\/\d{4}/,
  #                                message: "The date must be in the format MM/DD/YYYY and must be a date in the future." },
  #                      unless: Proc.new { |a| a.deadline && a.deadline.to_date >= Date.today }

  validate :deadline_in_future
  validate :require_one_approver
  validate :require_link

  accepts_nested_attributes_for :approvers,
                                reject_if: proc { |attributes| attributes['name'].blank? || attributes['email'].blank? },
                                allow_destroy: true

  def deadline_in_words
    string = distance_of_time_in_words_to_now(self.deadline).humanize

    if self.deadline > Time.now
      string << " remaining"
    else
      string << " ago"
    end
  end

  def update_permissions(file_id, user, approver, role = 'reader')
    user.refresh_google
    client = user.google_auth
    drive = client.discovered_api('drive', 'v2')# First retrieve the permission from the API.

    new_permission = drive.permissions.insert.request_schema.new({
      'value' => approver.email,
      'type' => 'user',
      'role' => role,
      'withLink' => 'true'
    })

    result = client.execute(api_method: drive.permissions.insert,
                            body_object: new_permission,
                            parameters: { 'fileId' => file_id, 'sendNotificationEmails'=>'false' })
    if result.status == 200
      return result.data
    # elsif result.status == 401 # token has expired
    #   user.refresh_google
    #   update_permissions(file_id, user, approver, role)
    else
      puts "An error occurred when setting permissions: #{result.data['error']['message']}"
    end
  end

    private

    def require_one_approver
      return unless approvers.empty?

      errors.add(:approvers, "You must include at least one approver. For each approver, please provide a name and email address so that we can contact them.")
    end

    def require_link
      return if link.present?

      errors.add(:link, "Please select a file or upload a new one.")
    end

    def deadline_in_future
      return if deadline.present? && deadline.to_date >= Date.today

      errors.add(:deadline, "Please select a deadline in the future")
    end
end
