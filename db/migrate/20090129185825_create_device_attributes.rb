class CreateDeviceAttributes < ActiveRecord::Migration
  def self.up
    
    create_table :device_attributes do |t|
      t.references :device
      t.string :name
      t.string :value
      t.timestamps
    end
    
    # device_atlas = DeviceAtlas.new
    # tree = device_atlas.getTreeFromFile(File.join(RAILS_ROOT, "data", "20090129.json"))
    # Device.transaction do
    #   device_atlas.user_agents(tree).each do |user_agent|
    #     puts "Device: #{user_agent}"
    #     device = Device.exists?(:user_agent => user_agent) ? Device.find_by_user_agent(user_agent) : Device.create!(:user_agent => user_agent)
    #     device_atlas.listProperties(tree).each do |prop, type|
    #       device_attribute = DeviceAttribute.new
    #       val = eval("device_atlas.getPropertyAs#{type.capitalize}(tree, user_agent, prop)") rescue next
    #       puts "Attribute: #{prop} = #{val}"
    #       device_attribute.name = prop.gsub(/\./,'_')
    #       device_attribute.value = val
    #       device_attribute.save!
    #     end
    #     device.save!
    #   end
    # end
    
  end

  def self.down
    drop_table :device_attributes
  end
end
