class AddLocationToKontactInformation < ActiveRecord::Migration
  def self.up
    add_column :kontact_informations, :location, :string
  end

  def self.down
    remove_column :kontact_informations, :location
  end
end
