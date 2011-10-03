# Settings specified here will take precedence over those in config/environment.rb


config.cache_classes = false

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = false

# needed for Avatar::Source::RailsAssetSource
config.action_controller.asset_host                  = "http://devlocal.7.am"
config.action_mailer.default_url_options = { :host => 'devlocal.7.am' }

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

config.action_mailer.delivery_method = :smtp  
config.action_mailer.smtp_settings = {  
  :address => "smtp.gmail.com",  
  :port => 587,  
  :user_name => "support@agilisto.com", 
  :password => "m@!l3r",
  :authentication => :plain
}

#debugger

#Synthesis::AssetPackage.merge_environments = ["production", "production_local"]

if File.exists?(File.join(RAILS_ROOT,'tmp', 'debug.txt'))
  require 'ruby-debug'
  Debugger.wait_connection = true
  Debugger.start_remote
  File.delete(File.join(RAILS_ROOT,'tmp', 'debug.txt'))
end