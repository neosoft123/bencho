class CreateBillingEntries < ActiveRecord::Migration
  def self.up
    create_table :billing_entries do |t|
      t.string :code
      t.string :reference
      t.string :reason
      t.references :account_entry
      t.timestamps
    end
  end

  def self.down
    drop_table :billing_entries
  end
end
