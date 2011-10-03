class AddOwnerToKontactInformation < ActiveRecord::Migration
  def self.up
    add_column :kontact_informations, :owner_id, :integer
    add_column :kontact_informations, :owner_type, :string
  end

  def self.down
    remove_column :kontact_informations, :owner_id
    remove_column :kontact_informations, :owner_type
  end
end
