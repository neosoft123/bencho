class AddWalletIdToAccountEntry < ActiveRecord::Migration
  def self.up
    add_column :account_entries, :wallet_id, :integer
  end

  def self.down
    remove_column :account_entries, :wallet_id
  end
end
