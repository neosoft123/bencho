# class User
# 
#   require 'bunny'
#   AMQP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/chat_daemon.yml")[RAILS_ENV]
# 
#   has_many :jabber_messages, :foreign_key => 'to_id', :order => 'created_at desc'
#   has_many :conversations, :foreign_key => 'owner_id', :class_name => 'JabberMessage'
#   named_scope :online, :conditions => {:online => true}
# 
#   def offline?
#     !online?
#   end
#   
#   def online!
#     self.update_attribute(:online, true)
#   end
#   
#   def offline!
#     self.update_attribute(:online, false)
#   end
#   
#   def subscribe_to(sub_user)
#     server.subscribe(self.id, sub_user.id)
#   end
# 
#   def signon(password)
#     online! if offline? # safety check so that users don't get stuck on chat login
#     server.signon(self.id, password)
#   end
#   
#   def force_signon(password)
#     online! if offline? # safety check so that users don't get stuck on chat login
#     server.force_signon(self.id, password)
#   end
# 
#   def signout
#     offline! if online? # safety check
#     server.signout(self.id)
#   end
#   
#   def send_message(to_user, message, opts={})
#     amqp_connect do |amqp|
#       exchange = amqp.exchange(AMQP_CONFIG["chat_exchange"], opts.update(:type => :topic))
#       exchange.publish(message.send(serialize_method), :key => to_user.chat_routing_key)
#     end
#   end
#   
#   def away(message=nil)
#     send_status :away, message
#   end
#   
#   def available(message=nil)
#     send_status :available, message
#   end
#   
#   # def ready_for_chat?
#   #   server.ready?(self.id)
#   # rescue DRb::DRbConnError => e
#   #   false
#   # end
#   # 
#   # def set_server server
#   #   @server = server
#   # end
#   
#   def chat_routing_key
#     "#{self.login}.chat.7.am"
#   end
#   
#   def status_routing_key
#     "#{self.login}.status.7.am"
#   end
#   
#   private
#   
#   def send_status status, message
#     amqp_connect do |amqp|
#       exchange = amqp.exchange(AMQP_CONFIG["status_exchange"], opts.update(:type => :topic))
#       exchange.publish(status, :key => self.status_routing_key)
#     end
#   end
#   
#   def amqp_connect opts={}
#     serialize_method = opts.delete(:method) || "to_json"
#     opts.update(:durable => true) unless opts.has_key?(:durable)
#     bunny = Bunny.new(:host => AMQP_CONFIG["amqp_host"], :logging => false)
#     bunny.start
#     yield bunny
#     bunny.stop
#   end
# 
# end
