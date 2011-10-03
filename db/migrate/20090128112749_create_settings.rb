class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.references :user
      t.string :twitter_login
      t.string :twitter_password
      t.boolean :send_status_to_facebook, :default => false
      t.boolean :upload_photos_to_facebook, :default => false
      t.string :fireeagle_request_token
      t.string :fireeagle_request_token_secret
      t.string :fireeagle_access_token
      t.string :fireeagle_access_token_secret
      t.timestamps
    end
    
    User.transaction do
      User.all.each do |user|
        settings = Settings.new(:user => user)
        %w(twitter_login twitter_password send_status_to_facebook upload_photos_to_facebook
          fireeagle_request_token fireeagle_request_token_secret
          fireeagle_access_token fireeagle_access_token_secret
        ).each do |m|
          eval "settings.#{m} = user.#{m}"
          settings.save!
        end
      end
    end
    
  end

  def self.down
    drop_table :settings
  end
end
