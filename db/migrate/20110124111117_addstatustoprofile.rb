class Addstatustoprofile < ActiveRecord::Migration
  def self.up
  add_column :profiles, :relation_status, :string
  end

  def self.down
   remove_column :profiles, :relation_status
  end
end
