class UserStatusToFacebook < ActiveRecord::Migration
  def self.up
    add_column :users, :send_status_to_facebook, :boolean, :default => false
  end

  def self.down
    remove_column :users, :send_status_to_facebook
  end
end
