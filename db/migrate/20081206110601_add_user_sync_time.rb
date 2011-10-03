class AddUserSyncTime < ActiveRecord::Migration
  def self.up
    add_column :users, :last_sync_started, :datetime
    add_column :users, :last_sync_finished, :datetime
  end

  def self.down
    remove_column :users, :last_sync_time
    remove_column :users, :last_sync_finished
  end
end
