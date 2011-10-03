class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.integer :owner_id
      t.boolean :is_public, :default => false
      t.string :name
      t.string :description
      t.timestamps
    end
    create_table :groups_profiles, :id => false do |t|
      t.references :profile
      t.references :group
    end
  end

  def self.down
    drop_table :groups
    drop_table :groups_members
  end
end
