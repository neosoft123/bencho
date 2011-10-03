class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.references :profile
      t.references :kontact
      t.string :code
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
