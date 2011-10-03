class AddIconToKontactInformation < ActiveRecord::Migration
  def self.up
    add_column :kontact_informations, :icon, :string
  end

  def self.down
    remove_column :kontact_informations, :icon
  end
end
