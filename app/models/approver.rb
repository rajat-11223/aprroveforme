class Approver < ActiveRecord::Base
  attr_accessible :email, :name, :required, :status, :comments, :code
  belongs_to :approval
  before_save { |approver| approver.email = approver.email.downcase }
  
  include ActionView::Helpers::DateHelper

  def to_s
    string = "Your approval is #{self.required}. ".humanize
    string << self.approval.deadline_in_words
  end

  def generate_code
  		o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
		string  =  (0...50).map{ o[rand(o.length)] }.join
		self.code = string
	end

end
