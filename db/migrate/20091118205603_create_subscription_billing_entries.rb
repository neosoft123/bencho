class CreateSubscriptionBillingEntries < ActiveRecord::Migration
  def self.up
    create_table :subscription_billing_entries do |t|
      t.string :code
      t.string :reference
      t.string :reason
      t.references :profile
      t.references :service
      t.string :aasm_state
      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_billing_entries
  end
end
