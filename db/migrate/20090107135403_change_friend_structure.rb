class ChangeFriendStructure < ActiveRecord::Migration
  def self.up
    add_column :friends, :state, :string
    
    Friend.transaction do 
      Friend.all.each do |friend|
        friend.state = (friend.status == Friend::ACCEPTED) ? 'friend' : 'follower'
        friend.save!
      end
    end
    
  end

  def self.down
    remove_column :friends, :state
  end
end
