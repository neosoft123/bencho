require 'rubygems'
require 'drb'
require 'drb/acl'
require 'optparse'
require 'yaml'
require 'xmpp4r-simple'

environment = ENV["RAILS_ENV"] || "development"
action = "start"

OptionParser.new do |opts|
  opts.banner = "Usage: chat_server [options] {start|stop|restart|run}"
  
  opts.on("-d", "--debug", "Print XMPP4R debug messages (only in fg mode)") do |v|
    Jabber.debug = true
  end
  
  opts.on("-e", "--environment ENV", "Run in specific Rails environment") do |e|
    environment = e
  end

  action = opts.permute!(ARGV)
  (puts opts; exit(1)) unless action.size == 1

  action = action.first
  (puts opts; exit(1)) unless %w(start stop restart run).include?(action)
end.parse!

#puts File.dirname(ENV["_"])
#puts File.dirname(__FILE__)

ENV["RAILS_ENV"] = environment

Dir.chdir(File.dirname(__FILE__))
puts "Changing path to #{Dir.pwd}"
%w(jabber_daemon jabber_server jabber_manager jabber_user pid_file).each { |f| require f }

JabberServer.send(action.to_sym)
