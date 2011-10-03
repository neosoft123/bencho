class MakeDeviceDefaultLevelMid < ActiveRecord::Migration
  def self.up
    remove_column :devices, :stylesheet_level
    add_column :devices, :stylesheet_level, :string, :default => 'mid'
  end

  def self.down
    remove_column :devices, :stylesheet_level
    add_column :devices, :stylesheet_level, :string, :default => 'low'
  end
end
