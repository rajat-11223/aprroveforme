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
