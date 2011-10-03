module HasBusinessCard
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def has_business_card
      has_one :business_card, :as => :owner
      has_many :business_card_profiles
      has_many :business_cards, :through => :business_card_profiles
      after_save :update_business_card
      include HasBusinessCard::InstanceMethods
    end
  
  end
  
  module InstanceMethods
    
    def has_business_card?
      return !self.business_card.nil?
    end
    
    def has_business_card_for? profile
      return false unless profile.has_business_card?
      return profile.business_card.is_shared_with?(self)
    end
    
    def has_requested_business_card_for? profile
      return BusinessCardRequest.exists?(:requester_id => self.id, :requested_id => profile)
    end
    
    def decline_to_share_business_card_with profile
      request = BusinessCardRequest.first(:conditions => {:requester_id => profile.id, :requested_id => self.id})
      request.destroy and return true if request
      return false
    end
    
    def share_business_card_with profile
      request = BusinessCardRequest.first(:conditions => {:requester_id => profile.id, :requested_id => self.id})
      return false unless request
      request.destroy if request
      create_business_card # in case we don't have one
      self.business_card.share_with(profile)
      true
    end
    
    def request_business_card_for profile
      BusinessCardRequest.create!(:requester => self, :requested => profile)
    end
    
    def create_business_card
      self.business_card = BusinessCard.create(:owner => self) unless self.business_card
      self.reload
      update_business_card
    end
    
    def update_business_card
      bc = self.business_card
      return unless bc
      bc.primary_email = self.email unless self.email.blank?
      bc.mobile = self.mobile unless self.mobile.blank?
      {
        'display_name'  => 'display_name',
        'given_name'    => 'given_name',
        'family_name'   => 'family_name',
        # 'email'         => 'primary_email.value',
        'mobile'        => 'mobile'
      }.each do |origin, destination|
        eval "bc.#{destination} = self.#{origin}"
      end
      bc.display_name = self.user.login if bc.f.blank? || bc.f.downcase == 'none'
      bc.save(false)
    end
    
  end
  
end

