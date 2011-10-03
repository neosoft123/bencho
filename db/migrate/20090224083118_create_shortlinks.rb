class CreateShortlinks < ActiveRecord::Migration
  def self.up
    create_table :shortlinks do |t|
      t.string :href
      t.string :href_code
      t.timestamps
    end
    add_index :shortlinks, :href
    add_index :shortlinks, :href_code
  end

  def self.down
    drop_table :shortlinks
  end
end
