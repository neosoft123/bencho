class Profile
  
  has_many :follower_ships, :class_name => 'Followship', :foreign_key => 'follower_id', :dependent => :destroy
  has_many :followed_ships, :class_name => 'Followship', :foreign_key => 'followed_id', :dependent => :destroy
  
  has_many :followers, :through => :followed_ships, :source => :follower
  has_many :followed, :through => :follower_ships, :source => :followed
  
  def followers_count
    followed_ships_count
  end
  
  def followed_count
    follower_ships_count
  end
  
  def followed_by?(other_profile)
    # other_profile.in? self.followers
    self.followers.include? other_profile
  end
  
  def following?(other_profile)
    # other_profile.in? self.followed
    self.followed.include? other_profile
  end
  
  def follow(other_profile)
    other_profile.followed_ships << Followship.new(:follower => self, :followed => other_profile)
  end
  
  def stop_following(other_profile)
    f = Followship.first(:conditions => { :follower_id => self.id, :followed_id => other_profile.id })
    f.destroy if f
  end
  
  def subscribe(other_profile)
    f = Followship.first(:conditions => {:follower_id => self.id, :followed_id => other_profile.id})
    f.update_attribute(:text_message_enabled, true) if f
  end
  
  def subscribed?(other_profile)
    f = Followship.first(:conditions => {:follower_id => self.id, :followed_id => other_profile.id})
    f.text_message_enabled
  end
  
  def unsubscribe(other_profile)
    f = Followship.first(:conditions => {:follower_id => self.id, :followed_id => other_profile.id})
    f.update_attribute(:text_message_enabled, false) if f
  end
  
end