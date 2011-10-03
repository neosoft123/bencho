class MessagesSingleTableInheritance < ActiveRecord::Migration
  def self.up
    add_column :messages, :type, :string, :default => 'Message'
  end

  def self.down
    remove_column :messages, :type
  end
end
