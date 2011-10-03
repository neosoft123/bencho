class AddWurflIndexes < ActiveRecord::Migration
  def self.up
    add_index :wurfl_devices, :xml_id
    add_index :wurfl_capabilities, :name    
  end

  def self.down
    remove_index :wurfl_devices, :xml_id
    remove_index :wurfl_capabilities, :name    
  end
end
