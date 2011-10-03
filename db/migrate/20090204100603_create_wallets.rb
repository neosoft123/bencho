class CreateWallets < ActiveRecord::Migration
  def self.up
    create_table :wallets do |t|
      t.integer :balance
      t.belongs_to :profile
      t.timestamps
    end
  end

  def self.down
    drop_table :wallets
  end
end
