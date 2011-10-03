class AddStaticMapToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :static_map_url, :string
  end

  def self.down
    remove_column :locations, :static_map_url
  end
end
