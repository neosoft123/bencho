class CreateGroupInvitations < ActiveRecord::Migration
  def self.up
    create_table :group_invitations do |t|
      t.references :group
      t.integer :inviter_id
      t.integer :invitee_id
      t.timestamps
    end
  end

  def self.down
    drop_table :group_invitations
  end
end
