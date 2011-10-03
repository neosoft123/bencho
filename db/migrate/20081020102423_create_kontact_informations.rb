class CreateKontactInformations < ActiveRecord::Migration
  def self.up
    # Based on the Portable Contacts Draft C specification
    create_table :kontact_informations do |t|
      t.string    :display_name, :size => 64
      t.string    :formatted_name
      t.string    :family_name
      t.string    :given_name
      t.string    :middle_name
      t.string    :honorific_prefix, :size => 16  # Mr, Mrs, Ms, Dr. etc.
      t.string    :honorific_suffix, :size => 16
      t.string    :nickname, :size => 24  # multiple
      t.date      :birthday
      t.date      :anniversary
      t.string    :gender
      t.string    :note
      t.string    :preferred_username
      t.datetime  :utc_offset
      t.boolean   :connected
      # Geo
      t.decimal   :longitude, :precision => 15, :scale => 10
      t.decimal   :latitude,  :precision => 15, :scale => 10
      
      t.timestamps
    end
  end

  def self.down
    drop_table :kontact_informations
  end
end
