class AddBillableFlagToTextMessage < ActiveRecord::Migration
  def self.up
    add_column :text_messages, :billable, :boolean, :default => true
  end

  def self.down
    remove_column :text_messages, :billable
  end
end
