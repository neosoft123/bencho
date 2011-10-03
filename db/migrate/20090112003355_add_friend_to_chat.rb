class AddFriendToChat < ActiveRecord::Migration
  def self.up
    add_column :chats, :to, :string
  end

  def self.down
    remove_column :chats, :to
  end
end
