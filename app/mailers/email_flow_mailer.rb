class EmailFlowMailer < ActionMailer::Base
  default from: "\"ApproveForMe\" <team@approveforme.com>"
  layout "email_flow"
end
