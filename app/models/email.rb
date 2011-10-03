# == Schema Information
# Schema version: 20081206110601
#
# Table name: plural_fields
#
#  id                     :integer(4)    not null, primary key
#  type                   :string(255)   
#  value                  :string(255)   
#  field_type             :string(255)   
#  primary                :boolean(1)    
#  created_at             :datetime      
#  updated_at             :datetime      
#  kontact_information_id :integer(4)    
#

class Email < PluralField
  
  validates_format_of :value, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'Email must be valid'
  
  def value
    return "" if self[:value] == "blank@email.com"
    super
  end
  
end
