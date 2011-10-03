class MigrateRemoveDupProfileKontactInformation < ActiveRecord::Migration
  def self.up
    profile_columns = [ :id , :user_id , :email , :created_at , :updated_at , :is_active , :last_activity_at , :lat , :lng , :location]
    Profile.columns.each do |column|
      remove_column :profiles , column.name.to_sym unless profile_columns.include?(column.name.to_sym)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
