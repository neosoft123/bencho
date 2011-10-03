class CreateDatingProfiles < ActiveRecord::Migration
  def self.up
    create_table :dating_profiles do |t|
      t.references :profile
      t.string :seeking
      t.integer :age_lowest
      t.integer :age_highest
      t.string :for
      t.string :sign
      t.integer :from_international_dialing_code_id
      t.timestamps
    end
  end

  def self.down
    drop_table :dating_profiles
  end
end
