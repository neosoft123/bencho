require File.dirname(__FILE__) + '/../test_helper'
require 'pp'

class JabberTest < ActiveSupport::TestCase  
  
  test "the jabber server" do
    
    %w(jabber_manager jabber_user).each do |r|
      require File.join(RAILS_ROOT, "lib", "xmpp", r)
    end
    
    puts "Loading config"
    config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'xmpp.yml'))[ENV['RAILS_ENV']]
    puts "Starting jabber manager"
    m = JabberManager.new(config['xmpp_domain'], true)
    
    john = User.find_by_login("johnp")
    john.jabber_messages.each { |jm| jm.destroy }
    john.set_server = m
    john.signon("pass")
    
    craig = User.find_by_login("craigp")
    craig.set_server = m
    craig.signon("pass")
    craig.offline!
    craig.send_message(john, "test message")
    
    john.reload
    assert_equal john.jabber_messages.count, 1
    puts john.jabber_messages.first
    
    craig.signout
    john.signout
    
  end
  
end