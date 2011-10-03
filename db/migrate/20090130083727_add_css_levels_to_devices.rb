class AddCssLevelsToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :stylesheet_level, :string, :default => 'low'
  end

  def self.down
    remove_column :devices, :stylesheet_level
  end
end
