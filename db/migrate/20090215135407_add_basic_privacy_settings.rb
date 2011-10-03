class AddBasicPrivacySettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :show_in_public_searches, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :show_in_public_searches
  end
end
