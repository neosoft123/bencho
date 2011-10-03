class AddImageColumnToKontactInformation < ActiveRecord::Migration
  def self.up
    add_column :kontact_informations , :image , :string 
  end

  def self.down
    remove_column :kontact_information , :image
  end
end
