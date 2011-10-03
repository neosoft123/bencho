class CreatePublicFeedItems < ActiveRecord::Migration
  def self.up
    create_table :public_feed_items do |t|
      t.integer :item_id
      t.string :item_type
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10
      t.timestamps
    end
  end

  def self.down
    drop_table :public_feed_items
  end
end
