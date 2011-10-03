class BusinessCard < KontactInformation

  belongs_to :owner, :polymorphic => :true
  has_many :business_card_profiles
  has_many :profiles, :through => :business_card_profiles
  
  def is_shared_with? profile
    return self.profiles.include?(profile)
  end
  
  def share_with profile
    self.business_card_profiles << BusinessCardProfile.create(:business_card => self, :profile => profile)
  end
  
end