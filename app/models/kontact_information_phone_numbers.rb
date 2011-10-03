class KontactInformation
  
  has_many :phone_numbers, :uniq => true, :dependent => :destroy
    
  attr_accessor :primary_phone_number
  
  after_save :save_phone_numbers
  validates_associated :phone_numbers
    
  def primary_phone_number
    primary_or_first phone_numbers
  end
  
  def primary_phone_number=(phone_number)
    
    phone_number = if phone_number.is_a?(String)
      if self.phone_numbers.exists?(:value => phone_number)
        self.phone_numbers.find_by_value(phone_number)
      else
        PhoneNumber.new(:value => phone_number, :kontact_information_id => self.id, :field_type => PhoneNumber::MOBILE)
      end
    else
      phone_number
    end
    
    set_primary_plural(phone_number, phone_numbers)
  end
    
  def save_phone_numbers
    phone_numbers.each do |phone_number|
      phone_number.save(false)
    end
  end
  
  # LDAP Mappings Helper Methods
  def home_phone=(value)
    hp = phone_numbers.find_or_initialize_by_field_type(PhoneNumber::HOME)
    hp.kontact_information = self
    hp.value = value
    hp.save(false)
  end
  
  # Mobile Phone
  def mobile=(value)
    hp = phone_numbers.find_or_initialize_by_field_type(PhoneNumber::MOBILE)
    hp.kontact_information = self
    hp.primary = true
    hp.value = value
    hp.save(false)
  end
  
  # Business Phone
  def telephone_number=(value)
    hp = phone_numbers.find_or_initialize_by_field_type(PhoneNumber::WORK)
    hp.kontact_information = self
    hp.value = value
    hp.save(false)
  end
  
  # Other telephone Number
  def other_telephone_number=(value)
    hp = phone_numbers.find_or_initialize_by_field_type(PhoneNumber::OTHER)
    hp.kontact_information = self
    hp.value = value
    hp.save(false)
  end
  
  # Fax
  def facimile_telephone_number=(value)
    hp = phone_numbers.find_or_initialize_by_field_type(PhoneNumber::FAX)
    hp.kontact_information = self
    hp.value = value
    hp.save(false)
  end
  
  def inplace_phone_number
    self.primary_phone_number ? self.primary_phone_number : self.build_inplace_phone_number
  end
  
  def build_inplace_phone_number
    e = PhoneNumber.new( {   :field_type => PhoneNumber::MOBILE , :value => "" , :primary => true  , :kontact_information_id => self.id } )
    e.save(false)
    e
  end
  
  def existing_phone_number_attributes=(phone_number_attributes)
    phone_numbers.reject(&:new_record?).each do |phone_number|
      attributes = phone_number_attributes[phone_number.id.to_s]
      if attributes
        phone_number.attributes = attributes
      else
        phone_numbers.delete(phone_number)
      end
    end
  end
  
end