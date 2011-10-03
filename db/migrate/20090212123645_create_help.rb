class CreateHelp < ActiveRecord::Migration
  
  def self.up
    create_table :help do |t|
      t.string      :controller, :limit => 100
      t.string      :action, :limit => 100
      t.text        :content
      t.timestamps
    end
    
    create_table :help_users, :id => false do |t|
      t.integer     :help_id
      t.integer     :user_id
    end
    
    add_index :help, [:controller, :action], :unique => true, :name => 'controller_action_unique'
  end
  
  def self.down
    drop_table :help
    drop_table :user_help
  end
  
end
