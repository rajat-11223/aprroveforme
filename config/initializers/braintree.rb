Braintree::Configuration.environment = ENV['BRAIN_TREE_ENV'].to_sym
Braintree::Configuration.logger = Logger.new('log/braintree.log')
Braintree::Configuration.merchant_id = ENV['BRAIN_TREE_MERCHANT_ID']
Braintree::Configuration.public_key = ENV['BRAIN_TREE_PUBLIC_KEY']
Braintree::Configuration.private_key = ENV['BRAIN_TREE_PRIVATE_KEY']
