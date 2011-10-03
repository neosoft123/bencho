class JabberUser
  
  attr_reader :domain, :user, :client, :jid
  
  def initialize(domain, user)
    log "Initializing jabber user for #{user.login}"
    @domain = domain
    @user = user
  end
  
  def login(manager, password)
    log "Logging into jabber server"
    @jid    = Jabber::JID.new("#{user.login}@#{domain}")
    @client = Jabber::Client.new(@jid)
    @client.connect
    @client.auth(password)
    log "Logged on"
    # listen_for_subscription_requests
    # listen_for_presence_notifications
    # listen_for_messages
    # send_initial_presence
    # get_roster
    # manager.user_ready(user, self)
    # Thread.stop
  end
  
  def get_roster
    log "Getting roster"
    @roster = Jabber::Roster::Helper.new(@client);
  end
  
  def send_initial_presence
    @client.send(Jabber::Presence.new.set_status("7am online at #{Time.now.utc}"))
  end
  
  def listen_for_subscription_requests
    @roster = Jabber::Roster::Helper.new(@client)
    @roster.add_subscription_request_callback do |item, pres|
      log "Accepting auth request from: " + pres.from.to_s
      @roster.accept_subscription(pres.from)
    end
  end

  def listen_for_messages
    log "Listening for messages"
    @client.add_message_callback do |m|
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
  
  def listen_for_presence_notifications
    log "Listening for presence notifications"
    @client.add_presence_callback do |m|
      case m.type
      when nil # status: available
        log "PRESENCE: #{m.from.to_short_s} is online"
      when :unavailable
        log "PRESENCE: #{m.from.to_short_s} is offline"
      end
    end
  end

  def send_message(to_user, message)
    to = "#{to_user.login}@#{domain}"
    log("Sending message to #{to}: #{message}")
    msg = Jabber::Message.new(to, message)
    msg.type = :chat
    @client.send(msg)
  end
  
  def logout
    @client.close
  end
  
  def log(message)
    puts message #if Jabber::debug
  end
  
end