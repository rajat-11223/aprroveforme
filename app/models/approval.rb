class Approval < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  attr_accessible :deadline, :description, :link, :title, :approvers_attributes, :embed, :link_title, :link_id, :link_type
  has_many :approvers, :dependent => :destroy
  validates :title, :link, :deadline, :presence => true
  validates :deadline, :format => { :with => /\d{2}\/\d{2}\/\d{4}/,
    :message => "The date must be in the format MM/DD/YYYY and must be a date in the future." }, :unless => Proc.new { |a| (a.deadline && (a.deadline.to_date > Date.today)) }
  accepts_nested_attributes_for :approvers, :reject_if => proc { |attributes| attributes['name'].blank? or attributes['email'].blank?}, :allow_destroy => true
  validate :require_one_approver

    def require_one_approver
    	if approvers.empty?
      		errors.add(:approvers, "You must include at least one approver. For each approver, please provide a name and email address so that we can contact them.") 
      	end
    end

    def deadline_in_words
      string = distance_of_time_in_words_to_now(self.deadline).humanize
      if self.deadline > Time.now
        string << " remaining. "
      else
        string << " ago. "
      end
    end

    def update_permissions(file_id, user, approver, role = 'reader')
      client = user.google_auth
      drive = client.discovered_api('drive', 'v2')# First retrieve the permission from the API.

      
      new_permission = drive.permissions.insert.request_schema.new({
        'value' => approver.email,
        'type' => 'user',
        'role' => role,
        'withLink' => 'true'
      })
      result = client.execute(
        :api_method => drive.permissions.insert,
        :body_object => new_permission,
        :parameters => { 'fileId' => file_id, 'sendNotificationEmails'=>'false' })
      if result.status == 200
        return result.data
      else
        puts "An error occurred when setting permissions: #{result.data['error']['message']}"
      end

    end
 
end
