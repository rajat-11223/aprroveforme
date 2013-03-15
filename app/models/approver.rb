class Approver < ActiveRecord::Base
  attr_accessible :email, :name, :required, :status
  belongs_to :approval
end
