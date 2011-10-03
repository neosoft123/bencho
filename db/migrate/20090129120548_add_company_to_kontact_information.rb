class AddCompanyToKontactInformation < ActiveRecord::Migration
  def self.up
    add_column :kontact_informations, :organization, :string
  end

  def self.down
    remove_column :kontact_informations, :organization
  end
end
