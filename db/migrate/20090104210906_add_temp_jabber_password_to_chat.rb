class AddTempJabberPasswordToChat < ActiveRecord::Migration
  def self.up
    add_column :chats, :jabber_password, :string
  end

  def self.down
    remove_column :chats, :jabber_password
  end
end
