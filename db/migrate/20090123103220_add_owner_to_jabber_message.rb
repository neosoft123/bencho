class AddOwnerToJabberMessage < ActiveRecord::Migration
  def self.up
    add_column :jabber_messages, :owner_id, :integer
  end

  def self.down
    remove_column :jabber_messages, :owner_id
  end
end
