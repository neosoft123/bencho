# Settings specified here will take precedence over those in config/environment.rb

config.after_initialize do
  Bullet.enable = false
  Bullet.alert = false
  Bullet.bullet_logger = true
  Bullet.console = true
#  Bullet.growl = true
#  Bullet.growl_password = "blister"
  Bullet.rails_logger = true
  Bullet.disable_browser_cache = true
end

require 'memcache'

memcache_servers = "127.0.0.1:11211"

#memcache_servers = ['127.0.0.1:11211', '127.0.0.1:11212']

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
#CACHE = MemCache.new('180.149.241.251')

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

config.cache_store = :mem_cache_store

# Cookie sessions (limit = 4K)
config.action_controller.session = {
  :session_key => '7am',
  :secret => '12224259caf0cfa4b51abc08404fc7960758a6c4',
  :expires => 1800
}
# config.action_controller.session_store = :active_record_store
config.action_controller.session_store = :mem_cache_store

# In the development environment your application's code is reloaded on
# every request. This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching = false
config.action_view.debug_rjs = true
config.action_controller.asset_host = "http://localhost:3000/"

# Don't care if the mailer can't send
config.action_mailer.default_url_options = { :host => 'http://localhost:3000/' }
config.action_mailer.raise_delivery_errors = true

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

$:.push("/usr/lib/ruby/site_ruby/1.8/RMagick.rb")

config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :user_name => "support@agilisto.com",
  :password => "m@!l3r",
  :authentication => :plain
}

