class AddLatitudeAndLongitudeToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :lat, :decimal, :precision => 15, :scale => 10
    add_column :profiles, :lng, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :profiles, :lat
    remove_column :profiles, :lng
  end
end
