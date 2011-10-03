class RemoveSettingsFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :send_status_to_facebook
    remove_column :users, :upload_photos_to_facebook
  end

  def self.down
    add_column :users, :send_status_to_facebook, :boolean, :default => false
    add_column :users, :upload_photos_to_facebook, :boolean, :default => false
  end
end
