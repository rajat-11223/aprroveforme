desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  puts "Updating feed..."
  NewsFeed.update
  puts "done."
end

task :send_reminders => :environment do
  User.send_reminders
end

desc "Update admin stats"
task :update_stats => :environment do
	User.all.each do |user|
		user.update_stats
	end
end