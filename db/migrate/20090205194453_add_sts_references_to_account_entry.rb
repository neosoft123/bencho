class AddStsReferencesToAccountEntry < ActiveRecord::Migration
  def self.up
    add_column :account_entries, :response_ref, :string
    add_column :account_entries, :error_code, :integer
  end

  def self.down
    remove_column :account_entries, :error_code
    remove_column :account_entries, :response_ref
  end
end
