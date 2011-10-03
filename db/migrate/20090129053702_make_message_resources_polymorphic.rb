class MakeMessageResourcesPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :messages, :sender_type, :string
    add_column :messages, :receiver_type, :string
    
    Message.transaction do
      Message.all.each do |msg|
        msg.update_attributes({:sender_type => 'Profile', :receiver_type => 'Profile'})
      end
    end
    
  end

  def self.down
    remove_column :messages, :sender_type
    remove_column :messages, :receiver_type
  end
end
