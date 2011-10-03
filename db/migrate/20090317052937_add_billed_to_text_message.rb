class AddBilledToTextMessage < ActiveRecord::Migration
  def self.up
    add_column :text_messages, :billed_to_id, :integer
  end

  def self.down
    remove_column :text_messages, :billed_to_id
  end
end
