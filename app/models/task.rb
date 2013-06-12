class Task < ActiveRecord::Base
  belongs_to :approval
  attr_accessible :comment, :status, :author, :approval_id
end
