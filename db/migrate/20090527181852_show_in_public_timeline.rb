class ShowInPublicTimeline < ActiveRecord::Migration
  def self.up
    add_column :settings, :show_in_public_timeline, :boolean, :default => true
  end

  def self.down
    remove_column :settings, :show_in_public_timeline
  end
end
