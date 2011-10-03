class ProfileKontactsCounterCache < ActiveRecord::Migration
  def self.up
    add_column :profiles, :kontacts_count, :integer
    
    Profile.transaction do
      Profile.all.each do |profile|
        profile.kontacts_count = profile.kontacts.count
        profile.save!
      end
    end 
    
  end

  def self.down
    remove_column :profiles, :kontacts_count
  end
end
