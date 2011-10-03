class AddActiveFlagToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :active, :boolean, :default => false
  end

  def self.down
    remove_column :services, :active
  end
end
