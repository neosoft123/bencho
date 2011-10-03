class AddBelongsToToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :profile_id, :integer
  end

  def self.down
    remove_column :locations, :profile_id
  end
end
