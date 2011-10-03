module Mobilised
    
  def mobile
    pn = phone_numbers.primary.mobile || phone_numbers.mobile.first
    pn.nil? ? build_primary_number : pn
  end
  
  def build_primary_number
    PhoneNumber.new({ :kontact_information_id => self.id , :primary => true , :field_type => PhoneNumber::MOBILE })
  end
  
  def mobile=(number)
    primary_phone_number = number                                                                              
  end
  
end