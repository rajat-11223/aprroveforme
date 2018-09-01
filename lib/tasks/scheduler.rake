desc "Update stats for users"
task update_stats: :environment do
  User.find_each do |user|
    User::StatUpdater.new(user).call
    print '.'
  end
end

desc "Sync Mail Contacts to our marketing system"
task sync_mail_contacts: :environment do |t|
  MailContacts::Sync.all!
end
