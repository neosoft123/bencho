class GlobalFeedItem < ActiveRecord::Base
  
  acts_as_commentable
  belongs_to :profile
  has_one :feed_item, :as => :item, :dependent => :destroy
  
  validates_presence_of :message
  
  after_create :feed_everyone
  
  def feed_everyone
    f = FeedItem.create!(:item => self)
    f.private!
    Profile.all.each { |p| p.feed_items << f }
  end
  
end
