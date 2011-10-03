class AddMappableInfoToProfileStatus < ActiveRecord::Migration
  def self.up
    add_column :profile_statuses, :latitude, :decimal, :precision => 15, :scale => 10
    add_column :profile_statuses, :longitude, :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :profile_statuses, :longitude
    remove_column :profile_statuses, :latitude
  end
end
