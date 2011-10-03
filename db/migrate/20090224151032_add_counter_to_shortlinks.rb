class AddCounterToShortlinks < ActiveRecord::Migration
  def self.up
    add_column :shortlinks, :click_count, :integer, :default => 0
  end

  def self.down
    remove_column :shortlinks, :click_count
  end
end
