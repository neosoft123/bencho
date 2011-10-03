class JabberManager
    
  def initialize(domain, noloop=false)
    log "Starting jabber manager"
    @domain = domain
    @jabber_users = {}
    trap('TERM') { do_exit }
    trap('INT') { do_exit }
    Thread.new do
      # counter = 10
      loop {
        sleep 30
        users = User.find @jabber_users.keys
        # users.each { |u| u.signout unless u.online? }
        log "Online users: #{users.map{|u|u.login}.join(', ')}"
        
        # fix "orphaned" online users, this is a bad solution
        User.online.each { |u| u.offline! unless users.include?(u) }
        
        # putting this check in, not the best way to do things, but it might
        # help solve the problem
        # users.each { |u| (u.online!;log("Setting #{u.login} online!")) if u.offline? }
                        
        STDOUT.flush
      }
    end unless noloop
  end
  
  def do_exit
    log "Shutting down, logging all users out"
    @jabber_users.keys.each { |uid| signout(uid) }
    User.online.each { |u| u.offline! } # safety net again
    exit(0)
  end
  
  def ping
    'pong'
  end
  
  def force_signon(user_id, password)
    user = User.find(user_id) rescue nil
    if user
      log "Signing on user: #{user.login}"
      Thread.new { JabberUser.new(@domain, user).login(self, password) }
    else
      log "User not found: #{user_id}"
    end
  end
  
  def signon(user_id, password)
    user = User.find(user_id) rescue nil
    unless ready?(user_id)
      if user
        log "Signing user on: #{user.login}"
        Thread.new { JabberUser.new(@domain, user).login(self, password) }
      else
        log "User not found: #{user_id}"
      end
    else
      log "User already signed on"
      user.online! if user.offline? if user
    end
  end
  
  def signout(user_id)
    user = User.find(user_id) rescue nil
    if user 
      if ready?(user_id)
        log "Signing user out: #{user.login}"
        @jabber_users[user_id].logout
      else
        user.offline! if user.online?
      end
    else
      log "User not found: #{user_id}"
    end
  end
  
  def remove_user(user)
    log "Removing #{user.login} from active list"
    @jabber_users.delete(user.id) if ready?(user.id)
  end
  
  def subscribe(user_id, sub_user_id)
    user = User.find(user_id) rescue nil
    if user && ready?(user_id)
      sub_user = User.find(sub_user_id) rescue nil
      @jabber_users[user_id].subscribe(sub_user) if sub_user
    else
      log "User not found"
    end
  end
  
  def[](user_id)
    @jabber_users[user_id]
  end
  
  def send_message(user_from_id, user_to_id, message)
    from = User.find(user_from_id) rescue nil
    to = User.find(user_to_id) rescue nil
    if from && to
      if ready?(user_from_id)
        log "Sending message from #{from.login} to #{to.login}"
        @jabber_users[user_from_id].send_message(to, message)
      else
        log "User #{from.login} trying to send message is not in active users list, signing them out"
        signout(user_from_id)
      end
    else
      log "Could not send message, users not found"
    end
  end
  
  def set_status(user_id, type, message=nil)
    user = User.find(user_id) rescue nil
    if user
      if ready?(user_id)
        @jabber_users[user_id].set_status(type, message)
      else
        signout(user_id)
      end
    end
  end
  
  def log(message)
    puts "MANAGER: #{message}" #if Jabber::debug
  end
  
  def ready!(user, jabber_user)
    log "User ready: #{user.login}"
    @jabber_users[user.id] = jabber_user
  end
  
  def ready?(user_id)
    @jabber_users.include?(user_id)
  end
    
end
