$:.unshift(File.dirname(__FILE__))

require 'lib/daemons/boot_daemon'

%w(chat_daemon).each { |f| require f }

ChatDaemon.send(@action.to_sym)
