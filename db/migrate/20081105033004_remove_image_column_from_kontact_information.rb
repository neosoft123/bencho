class RemoveImageColumnFromKontactInformation < ActiveRecord::Migration
  def self.up
    remove_column :kontact_informations , :image
  end

  def self.down
    add_column :kontact_informations , :image , :string
  end
end
