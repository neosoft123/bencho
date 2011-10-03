$:.unshift(File.join(File.dirname(__FILE__), "../../xmpp"))

require 'chat_user'

class ChatManager
  
  include DaemonLogging
    
  def initialize(domain, log_callback, options={})
    @log_callback = log_callback
    log "Starting chat manager"
    @domain = domain
    @chat_users = {}
    @cache_online_users_for = options.delete(:cache_online_users_for) || 30.seconds
  end
  
  def self.create_instance(domain, log_callback, options = {})
    @@instance = ChatManager.new(domain, log_callback, options)
  end
  
  def self.instance()
    if @@instance.nil?
      raise StandardError.new("Need to create manager first with parameters")
    end
    @@instance
  end
  
  def handle_mysql_error e, &block
    # HoptoadNotifier.notify(e)
    log red("MYSQL ERROR: #{e.message}")
    log green("Reconnecting to mysql")
    ActiveRecord::Base.connection.reconnect!
    yield if block_given?
  rescue => e
    raise e if RAILS_ENV == "development"
    HoptoadNotifier.notify(e)
    log red("MYSQL RECONNECT ERROR: #{e.message}")
    log red(e.backtrace)
  end
    
  def monitor
    users = Rails.cache.fetch("chat-users", :expires_in => @cache_online_users_for) { User.find @chat_users.keys }
    log "Online users (#{users.length}): #{cyan(users.map{|u|u.login}.join(', '))}"
    # fix "orphaned" online users, this is a bad solution
    User.online.each { |u| u.offline! unless users.include?(u) }
  rescue => e
    raise e if RAILS_ENV == "development"
    HoptoadNotifier.notify(e)
    log "MONITOR ERROR: #{e.message}"
  end
  
  def all_online_profiles
    users = Rails.cache.fetch("all_online_profiles", :expires_in => @cache_online_users_for) do 
      User.find(@chat_users.keys).collect {|u| u.profile }
    end
  rescue => e
    raise e if RAILS_ENV == "development"
    HoptoadNotifier.notify(e)
    log "CHAT USERS ERROR: #{e.message}"
  end
  
  def watch
    @chat_users.values.each { |chat_user| chat_user.watch }
 rescue => e
   raise e if RAILS_ENV == "development"
   HoptoadNotifier.notify(e)
   log "WATCH ERROR: #{e.message}"
  end
  
  def do_exit
    log "Shutting down, logging all users out"
    @chat_users.keys.each { |uid| signout(uid) }
    exit(0)
  end
  
  def ping
    'pong'
  end
  
  def force_signon(user_id, password)
    user = User.find(user_id)
    log "Signing on user: #{cyan(user.login)}"
    Thread.new { ChatUser.new(@domain, user, @log_callback).login(self, password) }
  rescue ActiveRecord::StatementInvalid => e
    handle_mysql_error(e) { force_signon(user_id, password) }
  end
  
  def signon(user_id, password)
    user = User.find(user_id)
    unless ready?(user_id)
      log "Signing user on: #{cyan(user.login)}"
      ChatUser.new(@domain, user, @log_callback).login(self, password)
    else
      log "User already signed on"
      user.online! if user.offline? if user
    end
  rescue ActiveRecord::RecordNotFound => e
    log red("Cannot find user: #{user_id}")
    HoptoadNotifier.notify(e)
    signout(user_id)
  rescue ActiveRecord::StatementInvalid => e
    handle_mysql_error(e) { signon(user_id, password) }
  end
  
  def signout(user_id)
    user = User.find(user_id) rescue nil
    if ready?(user_id)
      log "Signing user out: #{cyan(user.login)}"
      @chat_users[user_id].logout
    else
      user.offline! if user.online? if user
    end
    # ActiveRecord::Base.connection.disconnect! # testing only
  rescue ActiveRecord::StatementInvalid => e
    handle_mysql_error(e) { signout(user_id) }
  end
  
  def online_user_count
    @chat_users.length
  end
  
  def remove_user(user)
    log "Removing #{cyan(user.login)} from active list"
    @chat_users.delete(user.id) if ready?(user.id)
  end
  
  def subscribe(user_id, sub_user_id)
    user = User.find(user_id)
    if ready?(user_id)
      sub_user = User.find(sub_user_id) rescue nil
      @chat_users[user_id].subscribe(sub_user) if sub_user
    end
  rescue ActiveRecord::StatementInvalid => e
    handle_mysql_error(e) { subscribe(user_id, sub_user_id) }
  end
  
  def[](user_id)
    @chat_users[user_id]
  end
  
  def send_message(user_from_id, user_to_id, message)
    from = User.find(user_from_id)
    to = User.find(user_to_id)
    if ready?(user_from_id)
      log "Sending message from #{from.login} to #{to.login}"
      @chat_users[user_from_id].send_message(to, message)
    else
      log "User #{from.login} trying to send message is not in active users list, signing them out"
      signout(user_from_id)
    end
  rescue ActiveRecord::StatementInvalid => e
    handle_mysql_error(e) { send_message(user_from_id, user_to_id, message) }
  end
  
  def set_status(user_id, type, message=nil)
    user = User.find(user_id)
    if ready?(user_id)
      @chat_users[user_id].set_status(type, message)
    else
      signout(user_id)
    end
  rescue ActiveRecord::StatementInvalid => e
    handle_mysql_error(e) { set_status(user_id, type, message) }
  end
  
  def find_user user_id
    user = User.find(user_id) rescue nil
  end
  
  def log(message)
    @log_callback.call "#{red("MANAGER:")} #{message}"
    STDOUT.flush
  end
  
  def ready!(user, chat_user)
    log "User ready: #{cyan(user.login)}"
    @chat_users[user.id] = chat_user
  end
  
  def ready?(user_id)
    @chat_users.include?(user_id)
  end
    
end
