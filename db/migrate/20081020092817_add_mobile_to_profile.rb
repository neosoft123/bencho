class AddMobileToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :mobile, :string
  end

  def self.down
    remove_column :profiles, :mobile
  end
end
