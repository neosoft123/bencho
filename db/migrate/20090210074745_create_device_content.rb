class CreateDeviceContent < ActiveRecord::Migration
  
  def self.up
    create_table :device_content do |t|
      t.string      :vendor, :limit => 100
      t.string      :model, :limit => 100
      t.text        :sync_instructions
      t.timestamps
    end
    
    add_index :device_content, [:vendor, :model], :unique => true, :name => 'vendor_model_unique'
  end
  
  def self.down
    drop_table :device_content
  end
  
end
