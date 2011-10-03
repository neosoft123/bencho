class AddLuidToKontactInformation < ActiveRecord::Migration
  def self.up
    add_column :kontact_informations, :luid, :string
  end

  def self.down
    remove_column :kontact_informations, :luid
  end
end
