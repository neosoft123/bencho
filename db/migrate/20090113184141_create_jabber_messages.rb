class CreateJabberMessages < ActiveRecord::Migration
  def self.up
    create_table :jabber_messages do |t|
      t.integer :from_id
      t.integer :to_id
      t.string :message
      t.boolean :read, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :jabber_messages
  end
end
