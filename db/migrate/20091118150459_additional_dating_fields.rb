class AdditionalDatingFields < ActiveRecord::Migration
  def self.up
    add_column :dating_profiles, :international_dialing_code_id, :integer
    add_column :dating_profiles, :interests, :string
    add_column :dating_profiles, :gender, :string
    add_column :dating_profiles, :likes, :string
    add_column :dating_profiles, :dislikes, :string
  end

  def self.down
    remove_column :dating_profiles, :international_dialing_code_id
    remove_column :dating_profiles, :interests
    remove_column :dating_profiles, :gender
    remove_column :dating_profiles, :likes
    remove_column :dating_profiles, :dislikes
  end
end
