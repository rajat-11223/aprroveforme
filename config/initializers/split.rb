Split.redis = $redis

# how to ignore bots and ourselves in split tests
Split.configure do |config|
  config.experiments = {
    # This tests the header copy on the logged out page
    # find the files for this test in home/tests
    "Logged out copy test" => {
      :alternatives => ["home/tests/logged_out_header_control", "home/tests/logged_out_header_test"],
      :metric => :signed_in,
    },

  }
  # bot config
  #config.robot_regex = /my_custom_robot_regex/ # or
  #config.bots['newbot'] = "Description for bot with 'newbot' user agent, which will be added to config.robot_regex for exclusion"

  # IP config
  config.ignore_ip_addresses << "24.16.211.200" # or regex: /81\.19\.48\.[0-9]+/

  # or provide your own filter functionality, the default is proc{ |request| is_robot? || is_ignored_ip_address? }
  #config.ignore_filter = proc{ |request| CustomExcludeLogic.excludes?(request) }

  #config.allow_multiple_experiments = true

  #config.experiments = YAML.load_file "config/experiments.yml"
end
