require 'chronic'

class MoveShitBackToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :display_name, :string
    add_column :profiles, :family_name, :string
    add_column :profiles, :given_name, :string
    add_column :profiles, :middle_name, :string
    add_column :profiles, :gender, :string
    add_column :profiles, :birthday, :date
    add_column :profiles, :mobile, :string
  end

  def self.down
    remove_column :profiles, :display_name
    remove_column :profiles, :family_name
    remove_column :profiles, :given_name
    remove_column :profiles, :middle_name
    remove_column :profiles, :gender
    remove_column :profiles, :birthday
    remove_column :profiles, :mobile
  end
end
