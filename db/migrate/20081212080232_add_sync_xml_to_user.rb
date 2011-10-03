class AddSyncXmlToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :sync_xml, :text
  end

  def self.down
    remove_column :users, :sync_xml
  end
end
