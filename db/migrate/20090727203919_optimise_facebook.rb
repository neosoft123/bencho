class OptimiseFacebook < ActiveRecord::Migration
  def self.up
    add_column :facebook_statuses, :status_id, :bigint, :null => false
    FacebookStatus.all.each do |s|
      s.update_attribute(:status_id, s.facebook_status_id.to_i)
    end
    add_index :facebook_statuses, :status_id, :unique => true
    remove_column :facebook_statuses, :facebook_status_id
  end

  def self.down
    add_column :facebook_statuses, :facebook_status_id, :string
    FacebookStatus.all.each do |s|
      s.update_attribute(:facebook_status_id, :status_id.to_s)
    end
    remove_index :facebook_statuses, :status_id
    remove_column :facebook_statuses, :status_id
  end
end
