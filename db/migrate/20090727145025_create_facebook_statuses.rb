class CreateFacebookStatuses < ActiveRecord::Migration
  def self.up
    create_table :facebook_statuses do |t|
      t.references :profile
      t.string :facebook_status_id
      t.string :text
      t.string :name
      t.string :facebook_uid
      t.string :pic_square
      t.datetime :posted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :facebook_statuses
  end
end
