class AddServiceToTextMessage < ActiveRecord::Migration
  def self.up
    add_column :text_messages, :service_id, :integer
  end

  def self.down
    remove_column :text_messages, :service_id
  end
end
