class UsersRidesTheFireeagle < ActiveRecord::Migration
  def self.up
    add_column "users", :fireeagle_request_token, :string
    add_column "users", :fireeagle_request_token_secret, :string
    add_column "users", :fireeagle_access_token, :string
    add_column "users", :fireeagle_access_token_secret, :string
  end
 
  def self.down
    remove_column "users", :fireeagle_request_token
    remove_column "users", :fireeagle_request_token_secret
    remove_column "users", :fireeagle_access_token
    remove_column "users", :fireeagle_access_token_secret
  end
end