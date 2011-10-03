#require 'xmpp4r-simple'

class Friendship < ActiveRecord::Base
  
  belongs_to :friender, :class_name => 'Profile'
  belongs_to :friendee, :class_name => 'Profile'
  has_one :feed_item, :as => :item, :dependent => :destroy
  
  # named_scope :online_friends, :conditions => {:online => true}
  # named_scope :offline_friends, :conditions => {:online => false}
    
  acts_as_state_machine :initial => :pending
  
  state :pending
  state :accepted, :after => :accept_friendship
  
  event :accept do
    transitions :to => :accepted, :from => :pending
  end
  
  def accept_friendship
    transaction do
      f = Friendship.create!(:friender => self.friendee, :friendee => self.friender)
      f.update_attribute(:state, 'accepted')
      self.friender.feed_items << FeedItem.create!(:item => f)
      self.friender.follow(self.friendee) unless self.friender.following?(self.friendee)
      
      # send_im_auth_request
      # f.send_im_auth_request
    end    
  end
  
  # def send_im_auth_request
  #   im = Jabber::Simple.new("#{friender.user.login}@talk.7.am", friender.user.crypted_password)
  #   im.add("#{friendee.user.login}@talk.7.am")
  #   im.disconnect
  # end
  
end
