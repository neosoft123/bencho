class AddTwitterOauth < ActiveRecord::Migration
  def self.up
    add_column :settings, :send_status_to_twitter, :boolean
    add_column :settings, :twitter_oauth_token, :string
    add_column :settings, :twitter_oauth_secret, :string
  end

  def self.down
    remove_column :settings, :send_status_to_twitter
    remove_column :settings, :twitter_oauth_token
    remove_column :settings, :twitter_oauth_secret
  end
end
