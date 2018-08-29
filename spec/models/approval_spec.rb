require 'rails_helper'

describe Approval, focus: true do
  subject { build(:approval) }

  it 'valid' do
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
end
