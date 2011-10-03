class AddKontacts < ActiveRecord::Migration
  def self.up
    create_table :kontacts, :force => true do |t|
      t.integer :parent_id
      t.string  :parent_type
      t.integer :kontact_information_id
      t.string  :status
      t.timestamps
    end
  end

  def self.down
    drop_table :kontacts
  end
end
