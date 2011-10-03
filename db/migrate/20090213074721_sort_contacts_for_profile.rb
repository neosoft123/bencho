class SortContactsForProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :sort_contacts_last_name_first, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :sort_contacts_last_name_first
  end
end
