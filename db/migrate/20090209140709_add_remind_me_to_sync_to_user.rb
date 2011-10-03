class AddRemindMeToSyncToUser < ActiveRecord::Migration
  
  def self.up
    add_column :users, :remind_me_to_sync, :boolean, :default => true
  end
  
  def self.down
    remove_column :users, :remind_me_to_sync
  end
  
end
