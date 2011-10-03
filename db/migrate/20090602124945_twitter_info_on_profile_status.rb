class TwitterInfoOnProfileStatus < ActiveRecord::Migration
  def self.up
    add_column :profile_statuses, :twitter_status_id, :string
  end

  def self.down
    remove_column :profile_statuses, :twitter_status_id
  end
end
