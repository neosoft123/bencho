class LastTwitterCheck < ActiveRecord::Migration
  def self.up
    add_column :settings, :last_twitter_check, :datetime
  end

  def self.down
    remove_column :settings, :last_twitter_check
  end
end
