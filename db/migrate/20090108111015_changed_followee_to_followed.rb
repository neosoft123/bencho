class ChangedFolloweeToFollowed < ActiveRecord::Migration
  def self.up
    remove_column :followships, :followee_id
    add_column :followships, :followed_id, :integer
  end

  def self.down
    remove_column :followships, :followed_id
    add_column :followships, :followee_id, :integer
  end
end
