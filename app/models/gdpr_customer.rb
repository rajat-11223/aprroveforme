# == Schema Information
#
# Table name: gdpr_customers
#
#  id         :bigint(8)        not null, primary key
#  country    :string           default("t"), not null
#  email      :string           default("t"), not null
#  search     :string           default("t"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GdprCustomer < ApplicationRecord
end
