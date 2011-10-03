class Service < ActiveRecord::Base
  
  FEED_NOTIFICATION_SERVICE = "FeedNotification"
  CHAT_INVITE_SERVICE = "ChatInvite"
  FRIEND_INVITE_SERVICE = "FriendInvite"
  
  class << self
    
    def FeedNotificationService
      Service.find_by_title(FEED_NOTIFICATION_SERVICE)
    end
    
    def FriendInviteService
      Service.find_by_title(FRIEND_INVITE_SERVICE)
    end
    
  end
  
  money :price
  money :credit, :cents => :credit
  money :debit, :cents => :debit
  
  named_scope :active, :conditions => {:active => true}
end
