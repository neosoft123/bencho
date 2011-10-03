class PrivacySetting < PluralField
  SETTINGS = [ 'me' , 'friends' , 'everyone' ] 
  TYPES = [ 'search' , 'contact', 'additional' ]
  DEFAULT_OPTIONS = PluralField::DEFAULT_OPTIONS.merge(:field_type => TYPES[0])
  TYPE = PluralField::TYPE << [TYPES[0] , TYPES[1] , TYPES[2]]
  
  named_scope :basic, :conditions => {:field_type => TYPES[0]}
  named_scope :contact, :conditions => { :field_type => TYPES[1] }
  named_scope :additional, :conditions => { :field_type => TYPES[2] }
  
  named_scope :friends , :conditions => { :value => SETTINGS[0] }
  named_scope :followers , :conditions => { :value => SETTINGS[1] }
  named_scope :everyone , :conditions => { :value => SETTINGS[2] }
  
  attr_protected nil
end
