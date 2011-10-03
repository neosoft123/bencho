class AddsaveToInboxComment < ActiveRecord::Migration
  def self.up
    add_column :profile_statuses, :saveto_inbox, :boolean, :default => 0 
  end

  def self.down
    remove_column :profile_statuses, :saveto_inbox
  end
end
