class AddPasswordChangeReminderToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :password_reminder, :boolean
  end

  def self.down
    remove_column :users, :password_reminder
  end
end
