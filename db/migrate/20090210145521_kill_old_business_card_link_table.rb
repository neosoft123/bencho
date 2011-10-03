class KillOldBusinessCardLinkTable < ActiveRecord::Migration
  def self.up
    drop_table :business_cards_profiles
  end

  def self.down
    create_table :business_cards_profiles, :id => false do |t|
      t.references :business_card
      t.references :profile
    end
  end
end
