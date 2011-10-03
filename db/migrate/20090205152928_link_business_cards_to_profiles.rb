class LinkBusinessCardsToProfiles < ActiveRecord::Migration
  def self.up
    create_table :business_cards_profiles, :id => false do |t|
      t.references :business_card
      t.integer :shared_with_id
    end
  end

  def self.down
    drop_table :business_cards_profiles
  end
end
