class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :friender_id
      t.integer :friendee_id
      t.string :state 
      t.timestamps
    end
  end

  def self.down
    drop_table :friendships
  end
end
