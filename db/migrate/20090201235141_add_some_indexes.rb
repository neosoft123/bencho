class AddSomeIndexes < ActiveRecord::Migration
  def self.up
    begin
      add_index :kontacts, :parent_id, :unique => false
    rescue => e
      puts e.inspect
    end
    
    begin
      add_index :kontacts, :parent_type, :unique => false
    rescue => e
      puts e.inspect
    end
    
    begin
      add_index :kontact_informations, :id, :unique => true
    rescue => e
      puts e.inspect
    end

    begin
      add_index :kontact_informations, :created_at, :unique => false
    rescue => e
      puts e.inspect
    end
    
    begin
      add_index :kontact_informations, :updated_at, :unique => false
    rescue => e
      puts e.inspect
    end
    
    begin
      add_index :plural_fields, :type, :unique => false
    rescue => e
      puts e.inspect
    end
    
    begin
      add_index :plural_fields, :kontact_information_id, :unique => false
    rescue => e
      puts e.inspect
    end

    begin
      add_index :users, :login
    rescue => e
      puts e.inspect
    end
    
    begin
      add_index :plural_fields, :field_type
    rescue => e
      puts e.inspect
    end
    
    # CREATE  INDEX `index_plural_fields_on_field_type` ON `plural_fields` (`field_type`);
    # CREATE  INDEX `index_devices_on_user_agent` ON `devices` (`user_agent`);
    begin
      add_index :devices, :user_agent
    rescue => e
      puts e.inspect
    end
    
  end

  def self.down
    remove_index :kontacts, :parent_id
    remove_index :kontacts, :parent_type
    remove_index :kontact_informations, :id
    remove_index :kontact_informations, :created_at
    remove_index :kontact_informations, :updated_at
    remove_index :plural_fields, :type
    remove_index :plural_fields, :kontact_information_id
    remove_index :devices, :user_agent
    remove_index :profiles, :user_id
    remove_index :plural_fields, :field_type
    remove_index :users, :login
  end
end
