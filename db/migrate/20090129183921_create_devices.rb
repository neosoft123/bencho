class CreateDevices < ActiveRecord::Migration
  def self.up

    create_table :devices do |t|
      t.string :user_agent
      # device_atlas.listProperties(tree).each do |prop,type|
      #   eval "t.#{type} :#{prop.gsub(/\./,'_')}"
      # end
      t.timestamps
    end
    
  end

  def self.down
    drop_table :devices
  end
end
