class MobileActive < ActiveRecord::Migration
  def self.up
    create_table :wurfl_devices do |t|
      t.string :xml_id, :limit => 128, :null => false
      t.string :user_agent, :limit => 255, :default => nil
      t.string :fall_back, :limit => 128, :default => nil
      t.integer :actual_device_root
      t.timestamps
    end
    
    add_index :wurfl_devices, :xml_id
    
    create_table :wurfl_capabilities do |t|
      t.integer :wurfl_device_id, :null => false
      t.string :name, :limit => 128, :null => false
      t.string :value, :limit => 128, :null => false
    end
    
    add_index :wurfl_capabilities, :name
    
  end

  def self.down
    drop_table :wurfl_devices
    drop_table :wurfl_capabilities
  end
end