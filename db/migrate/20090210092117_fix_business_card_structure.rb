class FixBusinessCardStructure < ActiveRecord::Migration
  def self.up
    drop_table :business_cards_profiles
    create_table :business_cards_profiles, :id => false do |t|
      t.references :business_card
      t.references :profile
    end
  end

  def self.down
    drop_table :business_cards_profiles
    create_table :business_cards_profiles, :id => false do |t|
      t.references :business_card
      t.integer :shared_with_id
    end
  end
end
