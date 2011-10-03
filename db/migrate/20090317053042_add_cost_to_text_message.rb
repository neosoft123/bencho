class AddCostToTextMessage < ActiveRecord::Migration
  def self.up
    add_column :text_messages, :cost, :integer, :default => 1
  end

  def self.down
    remove_column :text_messages, :cost
  end
end
