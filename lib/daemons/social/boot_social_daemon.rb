$:.unshift(File.dirname(__FILE__))

require 'lib/daemons/boot_daemon'

%w(social_daemon).each { |f| require f }

SocialDaemon.send(@action.to_sym)
