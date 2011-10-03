# Settings specified here will take precedence over those in config/environment.rb

require 'memcache'

#memcache_servers = ['ec2-67-202-0-66.compute-1.amazonaws.com:11211']
memcache_servers = ['127.0.0.1:11211']
memcache_options = {
  :c_threshold => 10000,
  :compression => true,
  :debug => false,
  :namespace => '7am',
  :readonly => false,
  :urlencode => false,
  :autofix_keys => true
}
 cache_params = *([memcache_servers, memcache_options].flatten)
 CACHE = MemCache.new(*cache_params)
#CACHE = MemCache.new(memcache_servers, memcache_options)
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.merge!({ 'cache' => CACHE })

begin
   PhusionPassenger.on_event(:starting_worker_process) do |forked|
     if forked
       CACHE.reset
     end
   end
rescue NameError => error
end

config.cache_store = :mem_cache_store, '127.0.0.1:11211', memcache_options

#config.cache_store = :mem_cache_store


# Cookie sessions (limit = 4K)
config.action_controller.session = {
  :session_key => '7am',
  :secret      => '12224259caf0cfa4b51abc08404fc7960758a6c4',
  :expires     => 1800
}
#config.action_controller.session_store = :active_record_store
config.action_controller.session_store = :mem_cache_store 

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching = true

# needed for Avatar::Source::RailsAssetSource
config.action_controller.asset_host = "http://7.am"
config.action_mailer.default_url_options = { :host => '7.am' }

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

