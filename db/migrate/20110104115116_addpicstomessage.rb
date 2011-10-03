class Addpicstomessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :icon, :string
  end

  def self.down
     remove_column :messages, :icon
  end
end
