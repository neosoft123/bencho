module Jabber
  class Simple
    def safe_disconnect
      disconnect!(false)
    end
  end
end

class JabberUser
  
  WATCH_INTERVAL = 3
  PRESENCE_INTERVAL = 60
  LOGIN_RETRY_COUNT = 3

  class << self
    
    def jid_from_user(user, domain)
      "#{user.login}@#{domain}/omfg"
    end
    
    def login_from_jid(jid)
      jid =~ Regexp.new("(.*)@#{@domain}") ? $1 : nil
    end
    
  end
  
  def initialize(domain, user)
    @domain = domain
    @user = user
    @login_retry_count = 0
    log "initializing jabber user for domain: #{domain}"
  end
  
  def client
    return @client if @client && @client.connected?
    @client = Jabber::Simple.new(JabberUser.jid_from_user(@user, @domain), @password)
    return @client
  end
  
  def login(manager, password)
    @manager = manager
    @password = password
    @user.online! if @user.offline?
    set_status :available
    client.accept_subscriptions = true
    @manager.ready!(@user, self)
    check_subscriptions
    watch
  rescue => e # this is probably a timeout - in any case, make sure log the user out & mark him offline
    HoptoadNotifier.notify(e)
    log "LOGIN ERROR: #{e.message}"
    log e.backtrace
    logout(true)
  end
  
  def logout(reconnect=false)
    log "logging out"
    @user.offline! if @user.online?
    # @client.disconnect
    # strange code in gem was stopping reconnect - added this method in a monkeypatch
    client.safe_disconnect rescue nil
    if reconnect
      @login_retry_count += 1
      login(@manager, @password) if @login_retry_count < LOGIN_RETRY_COUNT
    end
  rescue => e
    HoptoadNotifier.notify e
    log "LOGOUT ERROR: #{e.message}"
    log e.backtrace
  ensure
    @manager.remove_user(@user)
  end
  
  def send_message(to, message)
    jid = JabberUser.jid_from_user(to, @domain)
    log "SENDING message to #{jid} => #{message}"
    JabberMessage.create!(:owner => @user, :from => @user, :to => to, :message => message) 
    client.deliver(jid, message)
  end
    
  def log(message)
    puts "USER:    #{@user.login}: #{message}" #if Jabber::debug
  end
  
  def check_subscriptions
    # log "checking subscriptions"
    @user.profile.friends.each do |f|
      # log "checking #{f.user.login}"
      subscribe(f.user)
    end
  end
  
  def subscribe(user)
    jid = JabberUser.jid_from_user(user, @domain)
    unless client.subscribed_to?(jid)
      # log "subscribing to #{jid}"
      client.add(jid)
    end
  end
  
  def set_status(type, message=nil)
    unless message
      message = @user.profile.reload.profile_statuses.current.text rescue nil
    end
    log "setting status to [#{type}] with message: #{message}"
    case type
    when :available
      client.status(nil, message)
    when :away
      client.status(:away, message)
    when :xa
      client.status(:xa, message)
    end
  end
  
  def handle_received_message msg
    jid = msg.from.strip.to_s
    log "RECEIVED message from #{jid} => #{msg.body}"
    from = User.find_by_login(JabberUser.login_from_jid(jid))
    if from
      m = JabberMessage.create!(:owner => @user, :from => from, :to => @user, :message => msg.body)
    else
      log "UNKNOWN user, cannot deliver => #{jid} (#{JabberUser.login_from_jid(jid)})"
    end
  end
    
  def watch
    
    log "starting chat monitor.."
    STDOUT.flush
    
    counter = 0
        
    loop do  
      client.received_messages do |msg|
        handle_received_message msg
      end

      client.presence_updates do |update|
        jid, status, message = *update
        user_login = JabberUser.login_from_jid(jid)
        unless user_login == @user.login
          # log "#{jid} is #{status} (#{message})" 
          from = User.find_by_login(user_login)
          if from
            
            # NOTE this code was to show users as online that were
            # logged in from jabber clients. Problem is that is can
            # cause a situation where users are kept online that
            # really aren't. Stopping the sending of constance
            # "available" statuses from site users should solve this..
            
            case status
            when :online
              log "#{jid} has come online"
              from.online! unless from.online?
            when :unavailable
              log "#{jid} has gone offline"
              from.offline! unless from.offline?
            end
          end
        end
      end

      client.new_subscriptions do |friend, presence|
        # log "subscription ==> #{friend.jid} (#{presence.type})"
        client.add(friend.jid) unless client.subscribed_to?(friend.jid) if friend && presence
      end
      
      sleep WATCH_INTERVAL
      
      counter += 1
      if counter == PRESENCE_INTERVAL
        p = @user.profile.reload
        # log "last activity was #{Time.now - p.last_activity_at} secs ago.." rescue nil
        if (Time.now - p.last_activity_at) > (PRESENCE_INTERVAL * 10)
          unless ['development', 'production_local'].include?(RAILS_ENV)
            break
          else
            set_status :xa
          end
        elsif (Time.now - p.last_activity_at) > (PRESENCE_INTERVAL * 2)
          set_status :xa
        elsif (Time.now - p.last_activity_at) > PRESENCE_INTERVAL
          set_status :away
        else
          # set_status :available
        end
        counter = 0
      end
      
      break if @user.offline?
      STDOUT.flush
      
    end

    logout# if @user.online?
    
    # log "leaving chat monitor.."

  rescue => e
    HoptoadNotifier.notify(e)
    log "WATCH ERROR: #{e.message}"
    log e.backtrace
    logout(true)
  end
  
end