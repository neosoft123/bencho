class AddProfileSmartbucksBonusIndicator < ActiveRecord::Migration
  def self.up
    add_column :profiles, :completion_bonus_awarded, :boolean, :default => false
  end

  def self.down
    remove_column :profiles, :completion_bonus_awarded
  end
end
