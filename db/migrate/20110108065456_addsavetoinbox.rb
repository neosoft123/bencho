class Addsavetoinbox < ActiveRecord::Migration
  def self.up
    add_column :messages, :saveto_inbox, :boolean, :default => 0 
  end

  def self.down
    remove_column :messages, :saveto_inbox
  end
end
