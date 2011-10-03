class AddGuidToKontactInformation < ActiveRecord::Migration
  def self.up
    add_column :kontact_informations, :uuid, :string, :limit => 36
    add_index :kontact_informations, :uuid
    KontactInformation.transaction do
      KontactInformation.all.each { |ki| ki.update_attribute(:uuid, UUID.random_create.to_s) }
    end
  end

  def self.down
    remove_index :kontact_informations, :uuid
    remove_column :kontact_informations, :uuid
  end
end
