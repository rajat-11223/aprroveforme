class Approval < ActiveRecord::Base
  attr_accessible :deadline, :description, :link, :title, :approvers_attributes
  has_many :approvers, :dependent => :destroy
  accepts_nested_attributes_for :approvers, :reject_if => proc { |attributes| attributes['name'].blank? or attributes['email'].blank?}, :allow_destroy => true

end
