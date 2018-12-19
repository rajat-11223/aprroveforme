# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.com/rails-environment-variables.html

["admin"].each do |role|
  Role.find_or_create_by(name: role)
end

rt = RequestType.find_or_initialize_by(slug: "approve")
rt.assign_attributes name: "Approval",
                     public: true,
                     affirming_text: "Approve",
                     dissenting_text: "Decline",
                     allow_dissenting: true,
                     initial_subject: "{{ request_title }} - APPROVAL request from {{ requester_name }}"

rt.initial_body = "Hello {{ responder_name }},

                    {{ requester_name }} included you as a {{ responder_required_status }} on their {{ request_title }} approval.

                    Go to the {{ request_title }} ApproveForMe page to approve or deny {{ requester_name }}’s request. You’ll be given a chance to add comments too.

                    [Respond Now]({{ link_to_request }})

                    —
                    {{ requester_name }} uses ApproveForMe to easily gather feedback and decisions on approvals and other requests. Users tell us they like the automated reminders to responders which encourages them to take action."
rt.reminder_subject = "Request from {{ requester_name }} - Approval of {{ request_title }}"
rt.reminder_body = "Hello {{ responder_name }},

                      This is a reminder that {{ owner_email  }} included you as a required responder on their {{ request_title }} {{ Id }}.

                      Visit the {{ request_link }} to approve or deny this request. You’ll be given a chance to add comments too.

                      BUTTON [Go to {{ request_title }}]({{ request_link }})

                      —
                      {{ requester_name }} uses ApproveForMe to easily gather feedback and decisions on approvals and other requests. Users tell us they like the automated reminders to responders which encourages them to take action."
rt.due_soon_subject = "Please approve {{ request_title }} now (Request from {{ requester_name }})"
rt.due_soon_body = "Hello {{ responder_name }},

                      This is a reminder that {{ requester_email }} included you as a required responder on their {{ request_title }} {{Id}}[lowercase].

                      Visit the {{ Id }} to {{ affirming_text }} or {{ dissenting_text }} this request. You’ll be given a chance to add comments too.

                      BUTTON [Go to {{ request_title }} {{ Id }}]"
rt.due_now_subject = "Feedback Needed on {{ request_title }} - {{ Id }} Request from {{ requester_name }}"
rt.due_now_body = "Hello {{ responder_email}},

                    {{ requester_email }} included you as a responder on {{ request_title }} and has been waiting for your response since <<request_started_date_time>>. Time has run out!

                    Please respond now. Your input will allow {{ requester_email }} to complete their work with {{ request_title }}.

                    Visit the {{ Id }} to {{ affirming_text }} or {{ dissenting_text }} this request. You’ll be given a chance to add comments too.

                    BUTTON [Go to {{ request_title }} {{ Id }}]"
rt.confirmation_responder_subject = "Thank You | {{ request_title }} - {{ Id}}[uppercase] Request from {{ requester_name }}"
rt.confirmation_responder_body = "Hi {{ responder_name }},

                                    We've recorded your {{ selected_option }} (along with any comments) for {{ requester_name }} in their {{ request_title }} approval. Thanks!

                                    - ApproveForMe

                                    —
                                    {{ requester_name }} uses ApproveForMe to organize the efforts of getting feedback and decisions on their approvals. Users tell us they like the automated reminders to responders which encourages them to take action."
rt.completed_request_subject = "Done! ApproveForMe and “{{ request_title }}”"
rt.completed_request_body = "Hello {{ requester_name }},

                              Thank you for using ApproveForMe. Your approval for {{ request_title }} is complete. All details about this {{ Id }}[lowercase] are available for review in your account.

                              include_if (<<deadline>> - <<completed_by_date>> > 2_days)
                              Your {{ Id }}[lowercase] was completed X_days before the deadline. Next time you see your responders ({{ email1}}, {{ email2 }}, {{ email3 }}), be sure to thank them for their help with this {{ request_title }} project. Your thankfulness may make their day and encourage them to support you again in the future with another speedy approval.

                              Thank you for choosing ApproveForMe.com for {{ request_title }}.
                              ApproveForMe

                              —
                              Help us make ApproveForMe better!
                              We actively use feedback to constantly improve our delivery process and provide users with the best possible service. This survey will take about 2 minutes.
                              [Start the survey](link_to_survey)

                              By using ApproveForMe, you agree to ApproveForMe.com’s [Privacy Notice](https://www.approveforme.com/privacy) and [Terms of Use](https://www.approveforme.com/terms).
                              This email was sent from a notification-only address that cannot accept incoming email. Please do not reply to this message."
rt.save!

rt = RequestType.find_or_initialize_by(slug: "confirmation")
rt.assign_attributes name: "Confirmation",
                     public: true,
                     affirming_text: "Confirm",
                     dissenting_text: "_",
                     allow_dissenting: false
rt.initial_subject = ""
rt.initial_body = ""
rt.reminder_subject = ""
rt.reminder_body = ""
rt.due_soon_subject = ""
rt.due_soon_body = ""
rt.due_now_subject = ""
rt.due_now_body = ""
rt.confirmation_responder_subject = ""
rt.confirmation_responder_body = ""
rt.completed_request_subject = ""
rt.completed_request_body = ""
rt.save!
