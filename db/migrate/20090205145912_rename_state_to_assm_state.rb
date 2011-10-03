class RenameStateToAssmState < ActiveRecord::Migration
  def self.up
    rename_column :account_entries, :status, :aasm_state
  end

  def self.down
    rename_column :account_entries, :aasm_state, :status
  end
end
