class DeviceContent < ActiveRecord::Base
  
  set_table_name :device_content
  
  validates_presence_of :model
  validates_presence_of :vendor
  validates_presence_of :sync_instructions
  validates_uniqueness_of :model, :scope => [:vendor], :message => 'The combination of vendor and model must be unique'
  
end
