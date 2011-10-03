class Friend < ActiveRecord::Base
  
  acts_as_state_machine :initial => :follower
  
  state :follower
  state :friend
  
  belongs_to :inviter, :class_name => 'Profile'
  belongs_to :invited, :class_name => 'Profile'
  
  after_create :create_feed_item
  after_update :create_feed_item
  # attr_immutable :id, :invited_id, :inviter_id
  
  # Statuses Array
  
  ACCEPTED = 1
  PENDING = 0
  
  def create_feed_item
    feed_item = FeedItem.create(:item => self)
    inviter.feed_items << feed_item
    invited.feed_items << feed_item
  end
    
  def validate
    errors.add('inviter', 'inviter and invited can not be the same user') if invited == inviter
  end
  
  def description user, target = nil
    return 'friend' if status == ACCEPTED
    return 'follower' if user == inviter
    'fan'
  end
  
  def after_create
    #trade_kontacts if self.status == ACCEPTED
    #AccountMailer.deliver_follow inviter, invited, description(inviter)
  end

  def after_save
    #trade_kontacts if self.status == ACCEPTED
  end

  def trade_kontacts
    puts "Checking to see if we're going to trade contacts.."
    unless Kontact.exists?({ :parent_type => 'Profile', :parent_id => self.inviter.id, :kontact_information_id => self.invited.kontact_information.id })
      puts "Creating contact for #{invited.full_name} on #{inviter.full_name}"
      Kontact.create_contact_kontact(self.inviter, self.invited.kontact_information, false)
    else
      puts "Contact already exists"
    end
    unless Kontact.exists?({ :parent_type => 'Profile', :parent_id => self.invited.id, :kontact_information_id => self.inviter.kontact_information.id })
      puts "Creating contact for #{inviter.full_name} on #{invited.full_name}"
      Kontact.create_contact_kontact(self.invited, self.inviter.kontact_information, false)
    else
      puts "Contact already exists"
    end
  rescue => e
    puts e.inspect
  end
  
  class << self
    
    def add_follower(inviter, invited)
      puts "Add follower"
      a = Friend.create(:inviter => inviter, :invited => invited, :status => PENDING)
      !a.new_record?
    end
  
    def make_friends(user, target)
      transaction do
        # begin
          Friend.find(:first, :conditions => {:inviter_id => target.id, :invited_id => user.id, :status => PENDING}).update_attributes({:status => ACCEPTED, :state => :friend})
          puts "Moved from follower to friend"
          Friend.create!(:inviter => user, :invited => target, :status => ACCEPTED, :state => :friend)
          puts "Created reciprocal friendship"
        # rescue => e
        #   puts e.inspect
        #   #return make_friends(target, user) if user.followed_by? target
        #   return add_follower(user, target)
        # end
      end
      true
    rescue => e
      RAILS_DEFAULT_LOGGER.error "ERROR MAKING FRIENDS: #{e.inspect}"
      false
    end
  
    def stop_being_friends(user, target)
      transaction do
        begin
          Friend.find(:first, :conditions => {:inviter_id => target.id, :invited_id => user.id, :status => ACCEPTED}).update_attribute(:status, PENDING)
          f = Friend.find(:first, :conditions => {:inviter_id => user.id, :invited_id => target.id, :status => ACCEPTED}).destroy
        rescue Exception
          return false
        end
      end
      true
    end
    
    def reset(user, target)
      #don't need a transaction here. if either fail, that's ok
      begin
        Friend.find(:first, :conditions => {:inviter_id => user.id, :invited_id => target.id}).destroy
        Friend.find(:first, :conditions => {:inviter_id => target.id, :invited_id => user.id, :status => ACCEPTED}).update_attribute(:status, PENDING)
      rescue Exception
        return true # we need something here for test coverage
      end
      true
    end
  
  end
  
end
