class Approver < ActiveRecord::Base
  attr_accessible :email, :name, :required, :status, :comments
  belongs_to :approval



end
