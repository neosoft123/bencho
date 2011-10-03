class AddPresenceToFriendship < ActiveRecord::Migration
  def self.up
    add_column :friendships, :online, :boolean, :default => false
  end

  def self.down
    remove_column :friendships, :online
  end
end
