class AddTextMessageEnabledToFollowship < ActiveRecord::Migration
  def self.up
    add_column :followships, :text_message_enabled, :boolean, :default => false
  end

  def self.down
    remove_column :followships, :text_message_enabled
  end
end
