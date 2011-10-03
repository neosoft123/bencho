class FacebookSessionExpired < ActiveRecord::Migration
  def self.up
    add_column :settings, :facebook_session_expired, :boolean, :default => false
  end

  def self.down
    remove_column :settings, :facebook_session_expired
  end
end
