desc "Update admin stats"
task update_stats: :environment do
  User.find_each do |user|
   user.update_stats
  end
end

desc "Sync Mail Contacts to our marketing system"
task sync_mail_contacts: :environment do |t|
  MailContacts::Sync.all!
end
