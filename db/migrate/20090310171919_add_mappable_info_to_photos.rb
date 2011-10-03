class AddMappableInfoToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :latitude, :decimal, :precision => 15, :scale => 10
    add_column :photos, :longitude, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :photos, :longitude
    remove_column :photos, :latitude
  end
end
