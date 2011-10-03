class CreateInternationalDialingCodes < ActiveRecord::Migration
  def self.up
    create_table :international_dialing_codes do |t|
      t.string :code, :length => 5
      t.string :country
      t.timestamps
    end

    require "csv"
    file = CSV::Reader.parse(File.open(File.join(RAILS_ROOT, "public", "countrycodes.csv")))
    file.each do |line|
      InternationalDialingCode.create(:code => line[0], :country => line[1])
    end
    
  end

  def self.down
    drop_table :international_dialing_codes
  end
end
