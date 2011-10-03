class AddStateToFeedItems < ActiveRecord::Migration
  def self.up
    add_column :feed_items, :state, :string
    FeedItem.transaction do
      FeedItem.all.each do |item|
        item.update_attribute(:state, 'public')
      end
    end
  end

  def self.down
    remove_column :feed_items, :state
  end
end
