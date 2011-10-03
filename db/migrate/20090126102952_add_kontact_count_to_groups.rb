class AddKontactCountToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :kontacts_count, :integer
  end

  def self.down
    remove_column :groups, :kontact_count
  end
end
