class CreateAccountEntries < ActiveRecord::Migration
  def self.up
    create_table :account_entries do |t|
      t.integer :debit
      t.integer :credit
      t.string :status
      t.string :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :account_entries
  end
end
