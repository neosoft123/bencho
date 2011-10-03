class AddMobileActivationKeyToUser < ActiveRecord::Migration
  def self.up
    add_column :users , :mobile_activation_code , :string  
    add_column :users , :mobile_activated_at , :datetime
  end

  def self.down
    remove_column :users , :mobile_activated_code
    remove_column :users , :mobile_activated_at
  end
end