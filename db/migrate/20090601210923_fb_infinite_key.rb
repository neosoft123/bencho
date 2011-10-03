class FbInfiniteKey < ActiveRecord::Migration
  def self.up
    add_column :settings, :facebook_infinite_session, :string
  end

  def self.down
    remove_column :settings, :facebook_infinite_session
  end
end
