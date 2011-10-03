class AddServiceIdToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :sts_service_id, :string
  end

  def self.down
    remove_column :services, :sts_service_id
  end
end
