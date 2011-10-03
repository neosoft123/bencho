class Comment < ActiveRecord::Base
  
  validates_presence_of :comment, :profile
  # attr_immutable :id, :profile_id, :commentable_id, :commentable_type
  
  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :profile
  
  has_one :feed_item, :as => :item, :dependent => :destroy
  
  def commentable_name
    if commentable.respond_to?(:display_commentable_as)
      commentable.display_commentable_as
    else
      commentable_type.titleize
    end
  end

  def after_create
    # feed_item = FeedItem.create(:item => self)
    # [profile].concat(profile.followers).each{ |p| p.feed_items << feed_item }
    FeedItem.create_feed_item(self, self.profile)
  end
  
  def self.between_profiles profile1, profile2
    find(:all, {
      :order => 'created_at desc',
      :conditions => [
        "(profile_id=? and commentable_id=?) or (profile_id=? and commentable_id=?) and commentable_type='Profile'",
        profile1.id, profile2.id, profile2.id, profile1.id]
    })
  end
end
