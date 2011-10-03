class Addyeartoprofile < ActiveRecord::Migration
  def self.up
   add_column :profiles, :birthyear, :integer
  end

  def self.down
  remove_column :profiles, :birthyear
  end
end
