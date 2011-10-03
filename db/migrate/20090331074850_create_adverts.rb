class CreateAdverts < ActiveRecord::Migration
  def self.up
    create_table :adverts do |t|
      t.string :title
      t.date :run_from
      t.date :run_to
      t.string :image
      t.integer :views, :default => 0
      t.integer :clicks, :default => 0
      t.string :send_to
      t.timestamps
    end
  end

  def self.down
    drop_table :adverts
  end
end
