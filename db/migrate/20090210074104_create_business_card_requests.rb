class CreateBusinessCardRequests < ActiveRecord::Migration
  def self.up
    create_table :business_card_requests do |t|
      t.integer :requester_id
      t.integer :requested_id
      t.timestamps
    end
  end

  def self.down
    drop_table :business_card_requests
  end
end
