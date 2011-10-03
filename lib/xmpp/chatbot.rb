class Chatbot < JabberUser
  
  LOGIN     = 'chatbot'
  PASSWORD  = 'chatbot'
  
  class << self
    
    def start(manager, domain)
      User.find_by_login(LOGIN).destroy
      User.new(:login => :chatbot, :password => PASSWORD).save(false) unless User.exists?(:login => LOGIN)
      chatter = Chatbot.new(domain)
      chatter.login(manager, PASSWORD)
    end
    
  end
  
  def initialize(domain)
    super domain, User.find_by_login(LOGIN)
  end
  
  def watch
    
    def log(message)
      puts "SEARCHBOT: #{message}"
    end
        
    loop do  
      begin
        @client.received_messages do |msg|
          jid = msg.from.strip.to_s
          log "received message from #{jid} => #{msg.body}"
          from = User.find_by_login(login_from_jid(jid))
          send_message(from, "RECEIVED MESSAGE")
        end

        @client.presence_updates do |update|
          jid, status, message = *update
          login = login_from_jid(jid)
          unless login == @user.login
            log "#{jid} is #{status} (#{message})" 
            from = User.find_by_login(login)
            if from
              case status
              when :online
                log "Setting #{jid} to #{status}"
                from.update_attribute(:online, true)
              when :unavailable
                from.update_attribute(:online, false)
              end
            end
          end
        end

        @client.new_subscriptions do |friend, presence|
          log "#{friend.jid} #{presence.type}"
          @client.add(friend.jid) unless @client.subscribed_to?(friend.jid)
        end
        
      rescue Exception => e
        log e.to_s
      end
      
      sleep WATCH_INTERVAL
      
    end
    
  end
    
end