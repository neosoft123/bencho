class Addtwitterid < ActiveRecord::Migration
  def self.up
     add_column :profile_statuses, :twitter_post_status, :string
  end

  def self.down
     remove_column :profile_statuses, :twitter_post_status
  end
end
