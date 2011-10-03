class AddHashToKontactInformation < ActiveRecord::Migration
  def self.up
    add_column :kontact_informations, :digest, :string
  end

  def self.down
    remove_column :kontact_informations, :digest
  end
end
