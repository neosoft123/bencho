class CreateProfileStatuses < ActiveRecord::Migration
  def self.up
    create_table :profile_statuses do |t|
      t.references :profile
      t.string :text, :limit => 140, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :profile_statuses
  end
end
