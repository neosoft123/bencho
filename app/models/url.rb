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

class Url < PluralField
end
