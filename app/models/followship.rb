class Followship < ActiveRecord::Base
  
  # acts_as_cached
  
  belongs_to :followed, :class_name => 'Profile', :counter_cache => :followed_ships_count
  belongs_to :follower, :class_name => 'Profile', :counter_cache => :follower_ships_count
  has_one :feed_item, :as => :item, :dependent => :destroy
  
  after_create :feedme
  
  named_scope :subscribed_to, :conditions => { :text_message_enabled => true }
  
  def feedme
    # f = FeedItem.create!(:item => self)
    # follower.feed_items << f
    # followed.feed_items << f
    FeedItem.create_feed_item(self, [follower, followed])
  end
  
  # def followed
  #   Profile.get_cache("profile-#{self.followed_id}") do
  #     p = Profile.find(self.followed_id)
  #     p.user = User.get_cache("user-#{p.user_id}") do
  #       User.find(p.user_id)
  #     end
  #     p
  #   end
  # end
  # 
  # def follower
  #   Profile.get_cache("profile-#{self.follower_id}") do
  #     p = Profile.find(self.follower_id)
  #     p.user = User.get_cache("user-#{p.user_id}") do
  #       User.find(p.user_id)
  #     end
  #     p
  #   end
  # end
    
end
