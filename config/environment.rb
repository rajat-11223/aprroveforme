# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Workflow::Application.initialize!

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if instance.error_message.kind_of?(Array)
    %(<div class="form-field error">#{html_tag}<small class="error">&nbsp;
      #{instance.error_message.join(',')}</small></div>).html_safe
  else
    %(<div class="form-field error">#{html_tag}<small class="error">&nbsp;
      #{instance.error_message}</small></div>).html_safe
  end
end

# AK 4.13.18 Configure ActionMailer for SendGrid
ActionMailer::Base.smtp_settings = {
  :user_name => ENV["SENDGRID_USERNAME"],
  :password => ENV["SENDGRID_PASSWORD"],
  :domain => 'approveforme.com',
  :address => 'smtp.sendgrid.net',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}