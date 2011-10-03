class Location < ActiveRecord::Base

  # acts_as_cached

  acts_as_commentable
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'
  belongs_to :profile
  has_one :feed_item, :as => :item, :dependent => :destroy
  
  def to_s
    self.title
  end
  
  def after_create
    FeedItem.create_feed_item(self, self.profile)
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
