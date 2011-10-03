include ActionController::UrlWriter

class FeedItem < ActiveRecord::Base  
  
  belongs_to :item, :polymorphic => true
  has_many :feeds, :dependent => :destroy
  # attr_immutable :id, :item_id, :item_type
  
  acts_as_state_machine :initial => :public
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'
  
  state :public
  state :private
  
  event :private do
    transitions :from => :public, :to => :private
  end
  
  before_save :geotag_me
  # after_create :send_notifications
  
  class << self
        
    def create_feed_item(item, profiles, private_feed_item=false)
      profiles = [*profiles]
      feed_item = FeedItem.create!(:item => item)
      have_been_fed = []
      profiles.each { |p| p.feed_items << feed_item; have_been_fed << p; }
      if private_feed_item
        feed_item.private!
      else
        PublicFeedItem.create!(:item => item) if profiles.first.user.settings.show_in_public_timeline?
        profiles.each{ |p| p.followers.each{ |f| f.feed_items << feed_item unless have_been_fed.include?(f); have_been_fed << f; } }
      end
      feed_item.send_notifications(profiles.first)    
    end
    
  end
  
  def partial
    item.class.name.underscore
  end
  
  # Copy location from target as that should be set as per the relevant user
  def geotag_me
    return true unless (item.respond_to?(:latitude) && item.latitude && item.respond_to?(:longitude) && item.longitude)
    self.latitude = item.latitude
    self.longitude = item.longitude
  end
    
  named_scope :for_profile_status,
    proc { |profile_status|
    {
      :conditions => { :item_type => 'ProfileStatus', :item_id => profile_status.id },
      :order => 'created_at desc'
    }
  }
  
  named_scope :public, :conditions => {:state => 'public'}
  
  
  # Named scopes don't like the geokit extenstions
  # TODO: How to get around this?
  named_scope :close_to,
    proc {|location, distance|
    {
      :conditions => {:origin => @location, :within => 50 }, 
      :order => 'distance asc'
    }
  }
  
  def self.find_for_profile profile
    # return_items = []
    # sql = <<-EOV
    #   select feed_items.* from feed_items
    #   where item_type in ('ProfileStatus', 'Photo', 'Location')
    #   and state = 'public'
    # EOV
    # items = FeedItem.find_by_sql(sql)
    # items.each do |item|
    #   next unless item.item.profile
    #   return_items << item if item.item.profile == profile
    # end
    
    h = {}

    profile.locations(:include => :feed_item).each do |item|
      h[item] = item.created_at
    end

    profile.profile_statuses(:include => :feed_item).each do |item|
      h[item] = item.created_at
    end
    
    profile.photos(:include => :feed_item).each do |item|
      h[item] = item.created_at
    end
    
    h = h.sort{ |a,b| b[1] <=> a[1] }
    
    h.map { |i| i[0].feed_item(:include => :item) }
  end
  
  def send_notifications profile
    
    RAILS_DEFAULT_LOGGER.debug "FEED ITEM SMS SENDING"
    
    # profile = KontactContext().profile
    return unless profile
    builder = SmsBuilder.new(:partial => "sms/#{partial}_feed")
    item, href = self.item, "#"

    message = builder.render_to_string(binding)
    service = Service.FeedNotificationService
    
    profile.followed_ships.each do |followed_ship|
      next unless followed_ship.text_message_enabled
      
      follower = followed_ship.follower

     # next unless follower.wallet.provided_for?(service.debit)
    
      text_message = profile.text_messages.create(
        :recipient => follower,
        :to => follower.mobile, 
        :message => message,
        :billable => true,
        :billed_to => follower,
        :service => service)

      Delayed::Job.enqueue(SmsJob.new(text_message.id))
    end 

  rescue Errno::ENOENT => e # No template yet
    RAILS_DEFAULT_LOGGER.error("Failed to queue SMS. #{e.message}", e)
  end
  
  # def item
  #   clazz = class_eval(item_type)
  #   if clazz.respond_to?(:get_cache)
  #     begin
  #       clazz.get_cache("#{item_type.underscore.dasherize}-#{item_id}") do
  #         clazz.find(item_id)
  #       end
  #     rescue
  #       clazz.find(item_id)
  #     end
  #   else
  #     clazz.find(item_id)
  #   end
  # end
  
end
