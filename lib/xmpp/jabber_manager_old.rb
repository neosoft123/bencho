require 'jabber_user'

class JabberManager
  
  attr_reader :domain
  
  def initialize(domain)
    log "Starting jabber manager"
    @domain = domain
    @jabber_users = {}
  end
  
  def signon(user, password)
    log "Signing on user: #{user.login}"
    jabber_user = JabberUser.new(domain, user)
    #Thread.new(self) { |manager| jabber_user.login(manager, password) }
    jabber_user.login(self, password)
    listen_for_subscription_requests(jabber_user)
    listen_for_presence_notifications(jabber_user)
    listen_for_messages(jabber_user)
    send_initial_presence(jabber_user)
    get_roster(jabber_user)
    user_ready(user, jabber_user)
  end
  
  def signout(user)
    log "Signing out user: #{user.login}"
    @jabber_users[user].logout
    @jabber_users.delete(user)
  end
  
  def[](user)
    @jabber_users[user]
  end
  
  def send_message(user_from, user_to, message)
    @jabber_users[user_from].send_message(user_to, message)
  end
  
  def log(message)
    puts message #if Jabber::debug
  end
  
  def user_ready(user, jabber_user)
    log "User ready: #{user.login}"
    @jabber_users[user] = jabber_user
  end
  
  def ready?(user)
    @jabber_users.include?(user)
  end
  
  def get_roster(jabber_user)
    log "Getting roster"
    roster = Jabber::Roster::Helper.new(jabber_user.client);
  end
  
  def send_initial_presence(jabber_user)
    log "Send initial presence"
    jabber_user.client.send(Jabber::Presence.new.set_status("7am online at #{Time.now.utc}"))
  end
  
  def listen_for_subscription_requests(jabber_user)
    log "Listening for subscription requests"
    roster = Jabber::Roster::Helper.new(jabber_user.client)
    roster.add_subscription_request_callback do |item, pres|
      log "Accepting auth request from: " + pres.from.to_s
      roster.accept_subscription(pres.from)
    end
  end

  def listen_for_messages(jabber_user)
    log "Listening for messages"
    jabber_user.client.add_message_callback do |m|
      log "MESSAGE TYPE: #{m.type}"
      log 'NO MESSAGE BODY' if m.body.nil?
      log "MESSAGE LENGTH: #{m.body.length}" unless m.body.nil?
      # unless m.type == :error
      #   case m.type
      #   when :chat
      #     unless m.body.nil?
      #       
      #     end
      #   end
      # end
    end
  end
  
  def listen_for_presence_notifications(jabber_user)
    log "Listening for presence notifications"
    jabber_user.client.add_presence_callback do |m|
      case m.type
      when nil # status: available
        log "PRESENCE: #{m.from.to_short_s} is online"
      when :unavailable
        log "PRESENCE: #{m.from.to_short_s} is offline"
      end
    end
  end
  
end
