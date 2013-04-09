class Approval < ActiveRecord::Base
  attr_accessible :deadline, :description, :link, :title, :approvers_attributes
  has_many :approvers, :dependent => :destroy
  validates :title, :link, :deadline, :presence => true
  validates :deadline, :format => { :with => /\d{2}\/\d{2}\/\d{4}/,
    :message => "The date must be in the format MM/DD/YYYY and must be a date in the future." }, :unless => Proc.new { |a| (a.deadline.to_date > Date.today) }
  accepts_nested_attributes_for :approvers, :reject_if => proc { |attributes| attributes['name'].blank? or attributes['email'].blank?}, :allow_destroy => true

 
end
