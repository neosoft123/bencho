class Profile
  
  has_one :dating_profile
  has_many :subscription_billing_entries, :order => "created_at desc"
  
end