class Photo < ActiveRecord::Base

  # acts_as_cached

  acts_as_commentable
  belongs_to :profile
  has_one :feed_item, :as => :item, :dependent => :destroy
  
  validates_presence_of :image, :profile_id
  # attr_immutable :id, :profile_id
  
  include Mapped
  before_save :geotag_me
  
  def after_create
    # feed_item = FeedItem.create(:item => self)
    # [profile].concat(profile.followers).each{ |p| p.feed_items << feed_item }
    FeedItem.create_feed_item(self, self.profile)
  end

  file_column :image, :magick => {
    :versions => { 
      :square => {:crop => "1:1", :size => "50x50", :name => "square"},
      :small => "175x250"
    }
  }
  
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
