class AddBillToToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :bill_to, :string
  end

  def self.down
    remove_column :services, :bill_to
  end
end
