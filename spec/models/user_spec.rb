require "rails_helper"

describe User do
  subject { build_stubbed(:user) }

  it { expect(subject).to be_valid }

  it "requires a picture" do
    subject.picture = nil
    expect(subject).to_not be_valid
  end

  it "requires an email" do
    subject.email = nil
    expect(subject).to_not be_valid
  end

  it "does not have a default last_login_at" do
    expect(subject.last_login_at).to be_nil
  end
end
