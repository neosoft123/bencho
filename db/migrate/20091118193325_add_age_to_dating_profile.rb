class AddAgeToDatingProfile < ActiveRecord::Migration
  def self.up
    add_column :dating_profiles, :age, :integer
  end

  def self.down
    remove_column :dating_profiles, :age
  end
end
