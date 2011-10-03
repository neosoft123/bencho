class Kontact < ActiveRecord::Base

  OWN = 'own'
  CONTACT = 'contact'

  belongs_to :kontact_information#, :dependent => :destroy
  belongs_to :parent, :polymorphic => true, :counter_cache => false
  validates_associated :kontact_information

  alias_method :ki, :kontact_information

  attr_protected nil
  
  delegate :email, :display_name, :formatted_name, :to => :kontact_information
  
  named_scope :sorted_by_last_name, :order => 'kontact_informations.family_name', :include => :kontact_information
  named_scope :sorted_by_first_name, :order => 'kontact_informations.given_name', :include => :kontact_information
  
  named_scope :by_letter,
    proc { |letter, profile|
      if profile.sort_contacts_last_name_first?
        {:conditions => ['family_name like :l', { :l => "#{letter}%" }]}
      else
        {:conditions => ['given_name like :l', { :l => "#{letter}%" }]}
      end
    }
     
   class << self
     def find_by_mobile_number profile, mobile
       sql = <<-EOV
         select kontacts.* from kontacts, kontact_informations, plural_fields
         where kontacts.parent_id = :pid
         and kontacts.parent_type = "Profile"
         and kontacts.kontact_information_id = kontact_informations.id
         and plural_fields.kontact_information_id = kontact_informations.id
         and plural_fields.type = "PhoneNumber"
         and plural_fields.field_type = "Mobile"
         and plural_fields.value = :mob
       EOV
       find_by_sql([sql, { :pid => profile.id, :mob => mobile }])
     end
   end
      
  def new_kontact_information_attributes=(attributes)
    self.kontact_information.build(attributes)
  end
      
  def validate_on_create
#    if self.class.count(:conditions => ["kontact_information_id = :kontact_information AND status in (:status)",
#      {:kontact_information => kontact_information, :status => OWN}]) > 0
#      errors.add_to_base("This Kontact is owned by someone else") and return
#    end
  end
  
  def avatar?
    self.kontact_information.icon ? true : false
  end
  
  def avatar(size=nil)
    return nil unless self.avatar?
    self.kontact_information.icon(size)
  end

  def self.create_own_kontact(parent, kontact_info, validate=true)
    parent.kontacts.new(
      :kontact_information => kontact_info,
      :status => OWN
    ).save(validate)
  end

  def self.create_contact_kontact(parent, kontact_info, validate=true)
    parent.kontacts.new(
      :kontact_information => kontact_info,
      :status => CONTACT
    ).save(validate)
  end
    
  def is_owner?(p)
    self.kontact_information.owner == p
  end
    
end
