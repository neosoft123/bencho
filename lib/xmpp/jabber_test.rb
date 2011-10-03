#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../config/environment'

require 'xmpp4r-simple'

require 'jabber_manager'

puts "Getting users.."
from = User.find_by_login 'craigp'
to = User.find_by_login 'henryd'

manager = JabberManager.new('talk.localhost')

puts "Signing on.. #{from.login}"
manager.signon(from, 'password')

loop {
  break if manager.ready?(from)
}
  
puts "Signing on.. #{to.login}"
manager.signon(to, 'pass')

loop {
  break if manager.ready?(to)
}
  
puts "Sending message.."
manager.send_message(from, to, 'test message')
manager.send_message(to, from, 'test message')

trap('TERM') { puts "Signing off"; manager.signout(from); manager.signout(to); exit }
trap('INT') { puts "Signing off"; manager.signout(from); manager.signout(to); exit }

Thread.stop


