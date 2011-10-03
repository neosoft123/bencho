class AddChatIdToChat < ActiveRecord::Migration
  def self.up
    add_column :chats, :chat_id, :string
  end

  def self.down
    remove_column :chats, :chat_id
  end
end
