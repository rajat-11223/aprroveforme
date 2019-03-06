desc "Update stats for users"
task update_stats: :environment do
  User.find_each do |user|
    User::StatUpdater.new(user).call
    print "."
  end
end

desc "Sync Mail Contacts to our marketing system"
task sync_mail_contacts: :environment do
  MailContacts::Sync.all!
end

desc "Send new Approval and Activation Emails"
task tickle_new_users: :environment do
  TickleNewUsers.new.call
end
