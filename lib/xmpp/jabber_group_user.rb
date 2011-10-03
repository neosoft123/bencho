class JabberGroupUser < JabberUser
  
  def initialize(domain, group)
    @domain = domain
    @group = group
    log "initializing jabber GROUP user for domain: #{domain}"
  end
  
  def watch
    
    log "starting GROUP chat monitor"
    
    counter = 0
        
    loop do  
      begin
        @client.received_messages do |msg|
          jid = msg.from.strip.to_s
          log "received message from #{jid} => #{msg.body}"
          from = User.find_by_login(JabberUser.login_from_jid(jid))
          @group.members.each do |member|
            send_message(member, msg.body) if member.online?
          end
          JabberMessage.create!(:owner => @user, :from => from, :to => @user, :message => msg.body) if from
        end

        @client.new_subscriptions do |friend, presence|
          log "#{friend.jid} #{presence.type}"
          @client.add(friend.jid) unless @client.subscribed_to?(friend.jid)
        end
        
      rescue Exception => e
        log e.to_s
      end
      
      sleep WATCH_INTERVAL
            
      STDOUT.flush
      
    end

    log 'jabber GROUP process terminating'
    
  end
  
end