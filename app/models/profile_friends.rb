require 'user'

class Profile
  
  FRIENDS_DISPLAY_LIMIT = 5
  
  has_many :requested_friendships, :class_name => 'Friendship', :foreign_key => 'friender_id', :conditions => { :state => 'pending' }
  has_many :friendships_requested, :class_name => 'Friendship', :foreign_key => 'friendee_id', :conditions => { :state => 'pending' }
  has_many :friendships, :foreign_key => 'friender_id', :conditions => { :state => 'accepted' }
  
  has_many :friends, :through => :friendships, :source => :friendee
  has_many :wanna_be_friends_with, :through => :requested_friendships, :source => :friendee
  has_many :wanna_be_friends_with_me, :through => :friendships_requested, :source => :friender
    
  def online_friends
    sql = <<-EOS
      select profiles.* from friendships, profiles, users
      where friendships.friender_id = ?
      and friendships.state = "accepted"
      and friendships.friendee_id = profiles.id
      and profiles.user_id = users.id
      and users.online = true
    EOS
    Profile.find_by_sql([sql, id])
  end
  
  def self.online_users
    Rails.cache.fetch("all-online-users", :expires_in => 5.minutes) do
      DRbObject.new(nil, XMPP_CONFIG['drb_server']).all_online_profiles rescue []
    end
  end
      
  def make_friends other_profile
    raise "Cannot friend self" if self == other_profile
    return if friend_of? other_profile
    if wants_to_be_my_friend? other_profile
      confirm_friendship other_profile
    else
      request_friendship other_profile
    end
  end
  
  def friend_of? other_profile
    # other_profile.in? friends
    friends.include? other_profile
  end
  
  def want_to_be_friend_of? other_profile
    # other_profile.in? wanna_be_friends_with
    wanna_be_friends_with.include? other_profile
  end
  
  def wants_to_be_my_friend? other_profile
    # other_profile.in? wanna_be_friends_with_me
    wanna_be_friends_with_me.include? other_profile
  end
    

  def request_friendship other_profile
    transaction do
      frn = Friendship.find(:all, :conditions =>{:friendee_id => other_profile, :friender_id => self, :state => 'pending' })
      if frn
	 frn.each do |fr|
	   friends_req = Friendship.first(:conditions => { :friendee_id => other_profile, :friender_id => self }) 
	   self.feed_items.find(:first, :conditions => { :item_type => 'Friendship', :item_id => friends_req.id } ).destroy
	   friends_req.destroy
	 end
      end
      f = Friendship.create!(:friendee => other_profile, :friender => self)
      item = FeedItem.create!(:item => f)
      item.private!
      self.feed_items << item
      other_profile.feed_items << item
    end
  end
  
  def confirm_friendship requesting_profile
    transaction do
      f = Friendship.first(:conditions => { :friendee_id => self.id, :friender_id => requesting_profile.id })
      f.accept!
      self.feed_items.find(:first, :conditions => { :item_type => 'Friendship', :item_id => f.id } ).destroy
      self.feed_items << FeedItem.create!(:item => f)
      self.follow(requesting_profile) unless self.following?(requesting_profile)
    end
    self.user.subscribe_to(requesting_profile.user)
    requesting_profile.user.subscribe_to(self.user)
  end
  
  def force_friendship profile
    transaction do
      Friendship.create!(:friendee => profile, :friender => self).update_attribute(:state, "accepted")
      Friendship.create!(:friendee => self, :friender => profile).update_attribute(:state, "accepted")
    end
    self.user.subscribe_to(profile.user)
    profile.user.subscribe_to(self.user)
  end
  
end
