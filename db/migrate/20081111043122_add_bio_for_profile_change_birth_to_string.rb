class AddBioForProfileChangeBirthToString < ActiveRecord::Migration
  def self.up
    add_column :kontact_informations , :about_me , :text
    change_column :kontact_informations , :birthday , :string
  end

  def self.down
    change_column :kontact_informations , :birthday , :datetime
    remove_column :kontact_informations , :about_me
  end
end
