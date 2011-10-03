class FacebookStatus < ActiveRecord::Base
  
  # acts_as_cached
  # include CachedProfile
  
  belongs_to :profile
  after_create :feedme
  has_one :feed_item, :as => :item, :dependent => :destroy
  
  def feedme
    FeedItem.create_feed_item(self, self.profile, true)
  end
    
end
