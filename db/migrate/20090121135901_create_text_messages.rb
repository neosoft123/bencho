class CreateTextMessages < ActiveRecord::Migration
  def self.up
    create_table :text_messages do |t|
      t.string :to
      t.string :message
      t.boolean :sent
      t.integer :profile_id
      t.timestamps
    end
  end

  def self.down
    drop_table :text_messages
  end
end
