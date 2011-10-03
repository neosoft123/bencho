class PluralField < ActiveRecord::Base
  HOME, WORK, OTHER = 'Home', 'Work', 'Other'
  TYPE = [HOME, WORK, OTHER]
  DEFAULT_OPTIONS = {:field_type => WORK, :primary => true}
  
  attr_accessor :should_validate
  
  named_scope :primary, :conditions => {:primary => true}
  named_scope :secondary, :conditions => {:primary => false}
  
  belongs_to :kontact_information
  
  def to_s
    value
  end
  
  # Contacts synchronized from mobile phones often in strange formats
  # This allows us to override the validation when the record is created
  # from a synchronization
  def should_validate?
    should_validate == true
  end
  
  def is_owner?(p)
    self.kontact_information.owner == p
  end
  
end
