require 'rails_helper'

describe Approver do
  let(:approval) { create(:approval) }
  subject { approval.approvers.first }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  it 'requires an approval' do
    subject.approval = nil

    expect(subject).to_not be_valid
  end

  xit 'requires a name' do
    subject.name = nil
    expect(subject).to_not be_valid
  end

  xit 'requires a email' do
    subject.email = nil
    expect(subject).to_not be_valid
  end

  it "generates random code" do
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
end
