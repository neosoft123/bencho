class ProfileStatus < ActiveRecord::Base
  
  # acts_as_cached
  # include CachedProfile

  acts_as_commentable
  belongs_to :profile
  validates_presence_of :text
  validates_length_of :text, :within => 3..340, :message => 'Please enter a status message'
  has_one :feed_item, :as => :item, :dependent => :destroy
  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'

  include Mapped
  
  after_create :feedme
  before_save :geotag_me
  
  def feedme
    # feed_item = FeedItem.create(:item => self)
    # [profile].concat(profile.followers).each{ |p| p.feed_items << feed_item }
    FeedItem.create_feed_item(self, self.profile)
  end
  
end

