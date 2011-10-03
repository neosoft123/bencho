class Addinteresttoprofile < ActiveRecord::Migration
  def self.up
   add_column :profiles, :description, :string
   add_column :profiles, :interest, :string
  end

  def self.down
   remove_column :profiles, :description
   remove_column :profiles, :interest
  end
end
