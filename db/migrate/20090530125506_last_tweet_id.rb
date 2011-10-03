class LastTweetId < ActiveRecord::Migration
  def self.up
    add_column :settings, :last_tweet_id, :integer
  end

  def self.down
    remove_column :settings, :last_tweet_id
  end
end
