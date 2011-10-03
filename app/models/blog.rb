class Blog < ActiveRecord::Base

  acts_as_commentable
  belongs_to :profile
  validates_presence_of :title, :body
  has_one :feed_item, :as => :item, :dependent => :destroy
  # attr_immutable :id, :profile_id
  
  def after_create
    feed_item = FeedItem.create(:item => self)
    [profile].concat(profile.followers).each{ |p| p.feed_items << feed_item }
  end
  
  def display_commentable_as
    "Diary Entry"
  end
  
  # def to_param
  #   "#{self.id}-#{title.to_safe_uri}"
  # end
    
end
