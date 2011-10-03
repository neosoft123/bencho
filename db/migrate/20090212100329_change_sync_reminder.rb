class ChangeSyncReminder < ActiveRecord::Migration
  
  def self.up
    add_column :users, :remind_to_sync_date, :datetime
    remove_column :users, :remind_me_to_sync
  end
  
  def self.down
    remove_column :users, :remind_to_sync_date
    add_column :users, :remind_me_to_sync, :boolean, :default => true
  end
  
end
