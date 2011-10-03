class AddHrefToTextMessage < ActiveRecord::Migration
  def self.up
    add_column :text_messages, :href, :string
  end

  def self.down
    remove_column :text_messages, :href
  end
end
