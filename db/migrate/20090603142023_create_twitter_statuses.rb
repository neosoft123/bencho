class CreateTwitterStatuses < ActiveRecord::Migration
  def self.up
    create_table :twitter_statuses do |t|
      t.references :profile
      t.string :tweet_id
      t.string :text
      t.string :name
      t.string :screen_name
      t.string :avatar_url
      t.datetime :posted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :twitter_statuses
  end
end
