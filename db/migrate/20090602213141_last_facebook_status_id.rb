class LastFacebookStatusId < ActiveRecord::Migration
  def self.up
    remove_column :settings, :last_tweet_id
    add_column :settings, :last_tweet_id, :string
    add_column :settings, :facebook_uid, :string
    add_column :settings, :last_facebook_status_id, :string
    add_column :profile_statuses, :facebook_status_id, :string
  end

  def self.down
    remove_column :settings, :last_tweet_id
    add_column :settings, :last_tweet_id, :integer
    remove_column :settings, :facebook_uid
    remove_column :settings, :last_facebook_status_id
    remove_column :profile_statuses, :facebook_status_id
  end
end
