class OptimiseTwitter < ActiveRecord::Migration
  def self.up
    add_column :twitter_statuses, :status_id, :bigint, :null => false
    TwitterStatus.all.each do |s|
      s.update_attribute(:status_id, s.tweet_id.to_i)
    end
    add_index :twitter_statuses, :status_id, :unique => true
    remove_column :twitter_statuses, :tweet_id
  end

  def self.down
    add_column :twitter_statuses, :tweet_id, :string
    TwitterStatus.all.each do |s|
      s.update_attribute(:tweet_id, s.status_id.to_s)
    end
    remove_index :twitter_statuses, :status_id
    remove_column :twitter_statuses, :status_id
  end
end
