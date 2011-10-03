class StiForKontactInformations < ActiveRecord::Migration
  def self.up
    add_column :kontact_informations, :type, :string, :default => 'KontactInformation'
  end

  def self.down
    remove_column :kontact_informations, :type
  end
end
