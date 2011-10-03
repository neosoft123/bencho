class AddServiceToAccountEntry < ActiveRecord::Migration
  def self.up
    add_column :account_entries, :service_id, :integer
  end

  def self.down
    remove_column :account_entries, :service_id
  end
end
