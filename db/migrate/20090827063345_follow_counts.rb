class FollowCounts < ActiveRecord::Migration
  def self.up
    add_column :profiles, :followed_ships_count, :int, :default => 0
    add_column :profiles, :follower_ships_count, :int, :default => 0
    
    Profile.all.each do |p|
      p.followed_ships_count = p.followed_ships.count
      p.follower_ships_count = p.follower_ships.count
      p.save!
    end
    
  end

  def self.down
    remove_column :profiles, :followed_ships_count
    remove_column :profiles, :follower_ships_count
  end
end
