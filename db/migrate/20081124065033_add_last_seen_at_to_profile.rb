class AddLastSeenAtToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :last_checkin, :datetime
  end

  def self.down
    remove_column :profiles, :last_checkin
  end
end
