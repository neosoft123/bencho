class CreateGroupMessages < ActiveRecord::Migration
  def self.up
    create_table :group_messages do |t|
      t.references :group
      t.string :text
      t.timestamps
    end
  end

  def self.down
    drop_table :group_messages
  end
end
