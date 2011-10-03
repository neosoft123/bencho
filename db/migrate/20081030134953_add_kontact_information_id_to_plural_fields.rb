class AddKontactInformationIdToPluralFields < ActiveRecord::Migration
  def self.up
    add_column :plural_fields, :kontact_information_id, :integer
  end

  def self.down
    remove_column :plural_fields, :kontact_information_id
  end
end
