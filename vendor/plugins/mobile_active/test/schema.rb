ActiveRecord::Schema.define(:version => 0) do
  create_table :devices do |t|
    t.string :user_agent
    t.timestamps
  end
  
  create_table :device_attributes do |t|
    t.references :device
    t.string :name
    t.string :value
    t.timestamps
  end
  
end