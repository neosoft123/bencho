class TwitterSupport < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_login, :string
    add_column :users, :twitter_password, :string
  end

  def self.down
    remove_column :users, :twitter_login
    remove_column :users, :twitter_password
  end
end
