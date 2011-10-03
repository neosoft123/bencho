module Chatter
  
  require 'drb'
  require 'drb/acl'

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def can_chat
      has_many :jabber_messages, :foreign_key => 'to_id', :order => 'created_at desc'
      has_many :conversations, :foreign_key => 'owner_id', :class_name => 'JabberMessage'
      named_scope :online, :conditions => {:online => true}
      include Chatter::InstanceMethods
    end

  end

  module InstanceMethods
    
    def online?
      if (ready_for_chat?)
        online! unless online
        true
      else
        offline! if online
        false
      end
    end
    
    def offline?
      if (ready_for_chat?)
        online!
        false
      else
        offline!
        true
      end
    end
    
    def online!
      self.update_attribute(:online, true)
    end
    
    def offline!
      self.update_attribute(:online, false)
    end
    
    def subscribe_to(sub_user)
      server.subscribe(self.id, sub_user.id)
    end

    def signon(password)
      online!
      server.signon(self.id, password)
    end
    
    def force_signon(password)
      server.force_signon(self.id, password)
    end

    def signout
      offline!
      server.signout(self.id)
    end
    
    def send_message(to_user, message)
      server.send_message(self.id, to_user.id, message)
    end
    
    def away(message=nil)
      server.set_status(self.id, :away, message)
    end
    
    def available(message=nil)
      server.set_status(self.id, :available, message)
    end
    
    def ready_for_chat?
      server.ready?(self.id)
    rescue DRb::DRbConnError => e
      false
    end
    
    def set_server server
      @server = server
    end
    
    private
    
    def server
      @server ||= get_server
      @server
    end
    
    def get_server
      DRbObject.new nil, XMPP_CONFIG['drb_server']
    end

  end

end
