require "rails_helper"

describe Approval::StatusChecker do
  subject { Approval::StatusChecker.new(approval) }

  context "complete" do
    let(:approval) { double(:approval, complete?: true) }

    it "should not be completed" do
      expect(subject.should_be_completed?).to eq(false)
    end
  end

  context "past deadline and not complete" do
    let(:approval) { double(:approval, deadline: 1.day.ago, complete?: false) }

    it "should be completed" do
      expect(subject.should_be_completed?).to eq(true)
    end
  end

  context "not past deadline, but all approvers responded, and not complete" do
    let(:approvers) { [double(:approver, has_responded?: true), double(:approver, has_responded?: true)] }
    let(:approval) { double(:approval, deadline: 5.day.from_now, complete?: false, approvers: approvers) }

    it "should be completed" do
      expect(subject.should_be_completed?).to eq(true)
    end
  end

  context "not past deadline, but one approver hasn't responded, and not complete" do
    let(:approvers) { [double(:approver, has_responded?: false), double(:approver, has_responded?: true)] }
    let(:approval) { double(:approval, deadline: 5.day.from_now, complete?: false, approvers: approvers) }

    it "should be completed" do
      expect(subject.should_be_completed?).to eq(false)
    end
  end
end
