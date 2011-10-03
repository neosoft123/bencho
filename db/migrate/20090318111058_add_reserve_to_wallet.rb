class AddReserveToWallet < ActiveRecord::Migration
  def self.up
    add_column :wallets, :reserve, :integer, :default => 0
  end

  def self.down
    remove_column :wallets, :reserve
  end
end
