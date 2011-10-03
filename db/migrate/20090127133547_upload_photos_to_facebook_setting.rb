class UploadPhotosToFacebookSetting < ActiveRecord::Migration
  def self.up
    add_column :users, :upload_photos_to_facebook, :boolean, :default => false
  end

  def self.down
    remove_column :users, :upload_photos_to_facebook
  end
end
