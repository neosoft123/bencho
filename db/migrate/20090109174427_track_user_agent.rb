class TrackUserAgent < ActiveRecord::Migration
  def self.up
    add_column :profiles, :last_user_agent, :string
  end

  def self.down
    remove_column :profiles, :last_user_agent
  end
end
