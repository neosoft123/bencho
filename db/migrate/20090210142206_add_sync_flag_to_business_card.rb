class AddSyncFlagToBusinessCard < ActiveRecord::Migration
  def self.up
    create_table :business_card_profiles do |t|
      t.references :business_card
      t.references :profile
      t.boolean :sync_to_phone, :default => false
    end
  end

  def self.down
    drop_table :business_card_profiles
  end
end
