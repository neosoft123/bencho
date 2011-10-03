class BusinessCardProfile < ActiveRecord::Base

  belongs_to :business_card
  belongs_to :profile
  has_one :feed_item, :as => :item, :dependent => :destroy
  after_create :feedme
  
  def feedme
    f = FeedItem.create(:item => self)
    f.private!
    self.profile.feed_items << f
  end
  
  class << self
    
    def set_sync_settings ids
      ids = [*ids]
      transaction do
        BusinessCardProfile.all.each do |bcp|
          bcp.update_attribute(:sync_to_phone, ids.include?(bcp.id))
        end
      end
    end
    
  end
    
end