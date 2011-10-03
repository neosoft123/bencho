class AddMappableInfoToFeedItem < ActiveRecord::Migration
  def self.up
    add_column :feed_items, :latitude, :decimal, :precision => 15, :scale => 10
    add_column :feed_items, :longitude, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :feed_items, :longitude
    remove_column :feed_items, :latitude
  end
end
