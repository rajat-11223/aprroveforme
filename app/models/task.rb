# == Schema Information
#
# Table name: tasks
#
#  id          :integer          not null, primary key
#  author      :integer
#  comment     :text
#  status      :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  approval_id :integer
#

class Task < ApplicationRecord
  belongs_to :approval
end
