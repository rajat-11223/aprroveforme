# == Schema Information
#
# Table name: approvers
#
#  id           :integer          not null, primary key
#  code         :string(255)
#  comments     :text             default(""), not null
#  email        :string           not null
#  name         :string           not null
#  required     :string           default("required"), not null
#  responded_at :datetime
#  status       :string           default("pending"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  approval_id  :integer          not null
#

require "rails_helper"

describe Approver do
  subject { create(:approver, :approved) }
  let(:approval) { approver.approval }

  it "has valid factory" do
    expect(subject).to be_valid
  end

  it "requires an approval" do
    subject.approval = nil

    expect(subject).to_not be_valid
  end

  it "requires a name" do
    subject.name = nil
    expect(subject).to_not be_valid
  end

  it "requires an email" do
    subject.email = nil
    expect(subject).to_not be_valid
  end

  it "generates random code, when asked" do
    expect(subject.code).to_not be_present

    subject.generate_code

    expect(subject.code).to be_present
    expect(subject.code).to be_a(String)
    expect(subject.code.size).to eq(50)
  end

  context "when email is set" do
    it "saves lowercase email on save" do
      subject.email = "UPPERcase@email.com"
      subject.save!
      expect(subject.email).to eq("uppercase@email.com")
    end
  end

  describe "status" do
    context "when created" do
      it "should allow pending" do
        expect(create(:approver, status: "pending")).to be_present
      end

      it "should now allow random" do
        expect { create(:approver, status: "rand") }.to raise_error ActiveRecord::RecordInvalid
      end
    end
    context "when updating" do
      subject { create(:approver, status: "pending") }

      xit "should not allow pending" do
        subject.status = "pending"
        expect(subject).to_not be_valid
      end

      it "should not allow random" do
        subject.status = "random"
        expect(subject).to_not be_valid
      end

      it "should allow approved" do
        subject.status = "approved"
        expect(subject).to be_valid
      end

      it "should allow declined" do
        subject.status = "declined"
        expect(subject).to be_valid
      end
    end
  end

  describe "scopes" do
    let!(:approval) { create(:approval) }

    context "with 0 emails" do
      it ".for_email" do
        result = Approver.for_email(nil)
        expect(result).to eq([])

        expect(Approver.count).to be >= 1
      end
    end

    context "with one emails" do
      let(:approver) { create(:approver, approval: approval, email: "ab@cd.com") }

      it ".for_email" do
        result = Approver.for_email("ab@cd.com")
        expect(result).to eq([approver])

        expect(Approver.count).to be >= 2
      end
    end

    context "when two emails" do
      let(:approver_two) { create(:approver, approval: approval, email: "ef@gh.com") }
      let(:approver) { create(:approver, approval: approval, email: "ab@cd.com") }

      it ".for_email" do
        result = Approver.for_email("ab@cd.com", "ef@gh.com")
        expect(result).to eq([approver, approver_two])

        expect(Approver.count).to be >= 3
      end
    end
  end
end
