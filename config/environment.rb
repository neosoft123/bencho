require 'rubygems'
gem 'soap4r'
require 'oauth'
require 'soap/rpc/driver' 

#RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  # config.logger = Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log", 'daily')

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  
  # Gem dependencies
  config.gem 'bullet'
  config.gem 'collectiveidea-money', :lib => 'money'
  config.gem 'json'
  config.gem 'rflickr', :lib => 'flickr'
  # config.gem 'colored'
  config.gem 'uuidtools'
  config.gem 'mocha'
  config.gem 'redgreen'
  config.gem "thoughtbot-factory_girl", :lib => "factory_girl"
  config.gem 'rubyist-aasm', :lib => 'aasm'
  config.gem 'chronic'
  config.gem 'avatar'
  # config.gem 'ar-extensions', :version => '0.8.0'
  config.gem 'geonames'
  config.gem 'httpclient'
  config.gem 'capistrano'
  config.gem 'oauth'
  # config.gem 'rspec', :lib => 'spec'
  config.gem 'soap4r'
  config.gem 'ruby-net-ldap', :lib => 'ldap'
  config.gem 'fireeagle'
  config.gem 'andre-geokit', :lib => 'geokit'
  # config.gem 'twitter4r', :lib => 'twitter', :version => '0.3.0'
  config.gem 'hpricot'
  config.gem 'static-gmaps', :lib => 'static_gmaps'
  config.gem 'RedCloth'
  config.gem 'jnunemaker-twitter', :lib => 'twitter'
  config.gem 'hoptoad_notifier'
end

