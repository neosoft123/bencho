class AddDatingSubsService < ActiveRecord::Migration
  def self.up
    Service.create(
      :title => "DatingSubscription",
      :description => "Dating Subscription",
      :price_in_cents => 700,
      :active => 1
    )
    add_column :dating_profiles, :last_billed, :datetime
  end

  def self.down
    Service.find_by_title("DatingSubscription").delete
    remove_column :dating_profiles, :last_billed
  end
end
