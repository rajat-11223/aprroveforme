class Approver < ActiveRecord::Base
  attr_accessible :email, :name, :required, :status, :comments
  belongs_to :approval
  include ActionView::Helpers::DateHelper

  def to_s
    string = "Your approval is #{self.required}. "
    string << self.approval.deadline_in_words
  end

end
