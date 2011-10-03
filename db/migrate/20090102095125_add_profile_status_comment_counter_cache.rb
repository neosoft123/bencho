class AddProfileStatusCommentCounterCache < ActiveRecord::Migration
  def self.up
    add_column :profile_statuses, :comments_count, :integer, :default => 0
  end

  def self.down
    remove_column :profile_statuses, :comments_count
  end
end
