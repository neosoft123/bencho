class CreatePluralFields < ActiveRecord::Migration
  def self.up
    create_table :plural_fields do |t|
      t.string :type
      t.string :value
      t.string :field_type
      t.boolean :primary
      t.timestamps
    end
  end

  def self.down
    drop_table :plural_fields
  end
end
