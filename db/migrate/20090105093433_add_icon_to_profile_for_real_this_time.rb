class AddIconToProfileForRealThisTime < ActiveRecord::Migration
  def self.up
    add_column :profiles, :icon, :string
  end

  def self.down
    remove_column :profiles, :icon
  end
end
