class LocationCommentCounterCache < ActiveRecord::Migration
  def self.up
    add_column :locations, :comments_count, :integer, :default => 0
  end

  def self.down
    remove_column :locations, :comments_count
  end
end
