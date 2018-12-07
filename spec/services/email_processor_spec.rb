require "spec_helper"

describe EmailProcessor, focus: true do
  let(:email) { build_email }
  let(:subject) { EmailProcessor.new(email) }

  it "processes an email" do
    expect { subject.process! }.not_to raise_error
  end

  context "when signed up" do
    let!(:from_user) { create(:user) }
    let!(:to_user) { create(:user) }
    let(:email) { build_email(to: [to_user], from: from_user) }

    it "do a thing" do
      expect { subject.process! }.not_to raise_error
    end
  end

  def build_email(attrs = {})
    details = {}
    if attrs[:to].present?
      attrs[:to].each do |u|
        details[:to] ||= []
        details[:to] << EmailExtractor.new(u).extract
      end
    end

    if attrs[:from].present?
      details[:from] = [EmailExtractor.new(attrs[:from]).extract]
    end

    build(:email, details)
  end
end

class EmailExtractor
  def initialize(user)
    @user = user
  end

  def extract
    {full: "#{@user.name} <#{@user.email}>", email: @user.email, token: @user.email.split("@").first, host: @user.email.split("@").last, name: @user.name}
  end
end
