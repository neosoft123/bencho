class AddRecipientToTextMessage < ActiveRecord::Migration
  def self.up
    add_column :text_messages, :recipient_id, :integer
  end

  def self.down
    remove_column :text_messages, :recipient_id
  end
end
