require "rails_helper"

describe UserMailer do
  context "when new user email" do
    let(:user) { create(:user, first_name: "John", email: "john@test.com") }

    it 'sends email' do
      email = UserMailer.new_user(user.name, user.email)

      expect(email.subject).to eq("Welcome to ApproveForMe!")
      expect(email.to).to eq(["john@test.com"])
      expect(email.from).to eq(["team@approveforme.com"])

      expect(email.body.encoded).to include("Welcome")
    end
  end

  context "when sending an approval, to owner" do
    let(:user) { create(:user, first_name: "John", email: "john@test.com") }
    let(:approval) { create(:approval, title: "<script>Payslip</script>", owner: user.id) }

    it 'sends email' do
      email = UserMailer.my_new_approval(approval)

      expect(email.subject).to eq("Payslip has been sent out for approval")
      expect(email.to).to eq(["john@test.com"])
      expect(email.from).to eq(["team@approveforme.com"])

      expect(email.body.encoded).to include("created a new approval")
    end
  end

  context "when sending an approval, to approver" do
    let(:user) { create(:user, name: "John", email: "john@test.com") }
    let(:approval) { create(:approval, title: "<script>Payslip</script>", owner: user.id) }
    let(:approver) { approval.approvers.first }

    it 'sends email' do
      email = UserMailer.new_approval_invite(approval, approver)

      expect(email.subject).to eq("John has requested your approval on Payslip")
      expect(email.to).to eq([approver.email])
      expect(email.from).to eq(["team@approveforme.com"])
      expect(email.reply_to).to eq(["john@test.com"])

      expect(email.body.encoded).to include("has requested your approval of")
    end
  end

  context "when an approver updates an approval" do
    let(:user) { create(:user, name: "John", email: "john@test.com") }
    let(:approval) { create(:approval, title: "<script>Payslip</script>", owner: user.id) }
    let(:approver) { approval.approvers.first }

    it 'sends email' do
      approver.update_attributes status: "approved"

      email = UserMailer.approval_update(approver)

      expect(email.subject).to eq("#{approver.name} has responded to Payslip")
      expect(email.to).to eq(["john@test.com"])
      expect(email.from).to eq(["team@approveforme.com"])

      expect(email.body.encoded).to include("Ricky Test has <b>approved</b>")
    end
  end

  context "when an approval is complete" do
    let(:user) { create(:user, name: "John", email: "john@test.com") }
    let(:approval) { create(:approval, title: "<script>Payslip</script>", owner: user.id) }
    let(:approver) { approval.approvers.first }

    it 'sends email' do
      approver.update_attributes status: "approved"

      email = UserMailer.completed_approval(approval)

      expect(email.subject).to eq("Payslip has been signed off!")
      expect(email.to).to eq(["john@test.com"])
      expect(email.from).to eq(["team@approveforme.com"])

      expect(email.body.encoded).to include("has been signed off by all required approvers.")
    end
  end
end
