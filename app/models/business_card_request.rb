class BusinessCardRequest < ActiveRecord::Base
  
  belongs_to :requester, :class_name => 'Profile'
  belongs_to :requested, :class_name => 'Profile'
  has_one :feed_item, :as => :item, :dependent => :destroy
  after_create :feedme
  
  def feedme
    f = FeedItem.create(:item => self)
    f.private!
    self.requested.feed_items << f
  end
  
end
