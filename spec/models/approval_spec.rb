# == Schema Information
#
# Table name: approvals
#
#  id              :integer          not null, primary key
#  completed_at    :datetime
#  deadline        :datetime         not null
#  description     :text             default(""), not null
#  drive_perms     :string(255)      default("reader")
#  drive_public    :boolean          default(TRUE), not null
#  embed           :string(255)
#  link            :string(255)
#  link_title      :string(255)
#  link_type       :string(255)
#  owner           :integer          not null
#  title           :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  link_id         :string(255)
#  request_type_id :bigint(8)
#
# Indexes
#
#  index_approvals_on_completed_at     (completed_at)
#  index_approvals_on_request_type_id  (request_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (request_type_id => request_types.id)
#

require "rails_helper"

describe Approval do
  subject { build(:approval) }

  it "valid" do
    expect(subject).to be_valid
  end

  it "requires a title" do
    subject.title = nil
    expect(subject).to_not be_valid
  end

  it "requires a deadline" do
    subject.deadline = nil

    expect(subject).to_not be_valid
  end

  it "requires a deadline in the future" do
    subject.deadline = 1.day.ago
    expect(subject).to_not be_valid
  end

  it "requires a link" do
    subject.link = nil

    expect(subject).to_not be_valid
  end

  it "reques at least one approver" do
    subject.approvers = []

    expect(subject).to_not be_valid
  end

  context "completeness" do
    subject! { create(:approval) }

    it "defaults to not complete" do
      expect(subject).to_not be_complete

      expect(Approval.complete.count).to eq(0)
      expect(Approval.not_complete.count).to eq(1)
    end

    it "is completeable" do
      subject.mark_as_complete!
      expect(subject).to be_complete

      expect(Approval.complete.count).to eq(1)
      expect(Approval.not_complete.count).to eq(0)
    end
  end
end
