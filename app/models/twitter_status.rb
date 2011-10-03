class TwitterStatus < ActiveRecord::Base
  
  # acts_as_cached
  
  belongs_to :profile
  after_create :feedme
  has_one :feed_item, :as => :item, :dependent => :destroy
  
  def feedme
    FeedItem.create_feed_item(self, self.profile, true)
  end
  
  # def profile
  #   Profile.get_cache("profile-#{self.profile_id}") do
  #     p = Profile.find(self.profile_id)
  #     p.user = User.get_cache("user-#{p.user_id}") do
  #       User.find(p.user_id)
  #     end
  #     p
  #   end
  # end
  
end
