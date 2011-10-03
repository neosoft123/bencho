class CreateServices < ActiveRecord::Migration
  def self.up
    create_table :services do |t|
      t.string :title
      t.string :description
      t.integer :price_in_cents
      t.integer :credit

      t.timestamps
    end
  end

  def self.down
    drop_table :services
  end
end
