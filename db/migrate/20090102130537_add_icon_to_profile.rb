class AddIconToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :about_me, :text
  end

  def self.down
    remove_column :profiles, :about_me
  end
end
