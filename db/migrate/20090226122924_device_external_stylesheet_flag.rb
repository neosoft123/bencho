class DeviceExternalStylesheetFlag < ActiveRecord::Migration
  def self.up
    add_column :devices, :use_external_stylesheet, :boolean, :default => true
  end

  def self.down
    remove_column :devices, :use_external_stylesheet
  end
end
