desc "Update admin stats"
task :update_stats => :environment do
  User.find_each do |user|
   user.update_stats
  end
end

desc "Sync MailContants to our marketing system"
task task_name: :environment do |t|
  MailContacts::Sync.all!
end
