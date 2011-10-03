class CreateGlobalFeedItems < ActiveRecord::Migration
  def self.up
    create_table :global_feed_items do |t|
      t.references :profile
      t.string :message
      t.integer :comments_count
      t.timestamps
    end
  end

  def self.down
    drop_table :global_feed_items
  end
end
