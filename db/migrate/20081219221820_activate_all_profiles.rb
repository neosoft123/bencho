class ActivateAllProfiles < ActiveRecord::Migration
  def self.up
    Profile.all.each do |p|
      p.update_attribute :is_active , true
    end
  end

  def self.down
  end
end
