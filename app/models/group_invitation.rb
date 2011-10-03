class GroupInvitation < ActiveRecord::Base
  
  belongs_to :group
  belongs_to :inviter, :class_name => 'Profile'
  belongs_to :invitee, :class_name => 'Profile'
  has_one :feed_item, :as => :item, :dependent => :destroy
  
  after_create :feed_me
  
  def feed_me
    f = FeedItem.create!(:item => self)
    f.private!
    invitee.feed_items << f
  end
    
  def accept
    transaction do
      self.group.join(self.invitee)
      # self.group.members << self.invitee unless self.group.is_member?(self.invitee)
      # self.invitee.feed_items.find(:first, :conditions => { :item_type => 'GroupInvitation', :item_id => self.id } ).destroy
      # self.feed_item.destroy
      
      # FeedItem.destroy(self.feed_item.id) if FeedItem.exists?(self.feed_item.id)
      # thinking now that a group invitation should be destroyed anyway when its accepted
      GroupInvitation.destroy(self.id)
    end
  end
  
  def decline
    transaction do
      # self.invitee.feed_items.find(:first, :conditions => { :item_type => 'GroupInvitation', :item_id => self.id } ).destroy
      # self.feed_item.destroy
    
      # self.destroy
      GroupInvitation.destroy(self.id)
    end
  end
  
end
