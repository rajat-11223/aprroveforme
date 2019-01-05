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

require 'rails_helper'

describe Task do
  pending "add some examples to (or delete) #{__FILE__}"
end
