require 'digest/md5'
require 'uuidtools'
# Marker comment, the previous commit contained the work enabling better mapping support for kontact informations. 
class KontactInformation < ActiveRecord::Base

  include Locationised
  include Mobilised
  

  concerned_with :phone_numbers, :email_addresses

  acts_as_mappable :lat_column_name => 'latitude', :lng_column_name => 'longitude'

  # Commented out as part of 2.2.2 -> 2.3.5 migration
  # acts_as_taggable_on :locations
  
  attr_protected nil
  # Allows plural fields to bypass validation if originating from sync
  attr_accessor :should_validate
  
  has_many :kontacts, :dependent => :destroy
  
  validates_associated :urls
    
  has_many :profile_parents, :through => :kontacts, 
    :source => :parent, :source_type => 'Profile'
      
  belongs_to :owner, :polymorphic => :true
  
  # Plural Fields 
  has_many :urls, :uniq => true,  :dependent => :destroy
  
  before_create :split_display_name, :create_uuid
    
  # Constants
  GENDER = [['Male', 'male'], ['Female', 'female'], ['Other','other']]
    
  def on_create_of_profile?
    if self.phone_numbers.size == 1
      return self.mobile(true).primary && self.mobile(true).value.blank?
    end
  end
    
  def calc_digest
    Digest::MD5.hexdigest(self.display_name)
  end
  
  def formal_name(profile=nil)
    names = [family_name, given_name]
    if profile.nil? or profile.sort_contacts_last_name_first?
      names.compact.join(', ')
    else
      names.reverse.compact.join(' ')
    end
  end
  
  def formatted_name
    unless display_name.blank?
      display_name
    else
      name = [given_name, family_name].join(' ')
      unless name.blank?
        name
      else
        'None'
      end
    end
  end
  
  alias_method :f, :formatted_name
  alias_method :full_name, :formatted_name
  
  def first_name
    self[:given_name]
  end
  
  def first_name=(name)
    self[:given_name] = name
  end
  
  def last_name
    self[:family_name]    
  end
  
  def last_name=(name)
    self[:family_name] = name
  end
  
  def years_old
    return 0 unless birthday
    # parse with chronic first, its more forgiving and returns nil, doesn't raise error
    date = Chronic.parse(birthday)
    date = Date.parse(birthday) unless date
    return (Date.today.year - date.year) - (Date.today.yday < date.yday ? 1 : 0)
  rescue
    return 0
  end
    
  public
  
  def touch
    update_attribute(:updated_at, DateTime.now)
  end

#	private static final String supportedAttributes[] = { "givenName", "sn",
#			"telephoneNumber", "description", "title",
#			"facsimileTelephoneNumber", "postalCode", "postalAddress", "st",
#			"l", "homePhone", "mobile", "homePostalAddress", "initials",
#			"mail", "street" };

   def to_ldap_entry
     {	
 		  "objectclass"     => ["top", "person", "organizationalPerson", "inetOrgPerson", "mozillaOrgPerson"],
 			"nsUniqueId"      => [uuid],
 			"EntryUUID"       => [uuid],
  		"sn"              => [family_name],
   		"givenName"       => [given_name],
   		"uid"             => [id],
 			"cn"              => [formatted_name],
   		"title"           => [honorific_prefix],
   		"displayName"     => [display_name],
   		"l"               => [location],
   		"o"               => [organization],
   		"description"     => [note]
 		}.merge!(phone_numbers_to_ldap).merge!(emails_to_ldap)
 	end
  
  
  protected
  def phone_numbers_to_ldap
    entries = {}
    phone_numbers.each do |pn|
      case pn.field_type
        when 'Home'
          entries.merge!({'homePhone' => pn.value})
        when 'Work'
          entries.merge!({'telephoneNumber' => pn.value})
        when 'Mobile'
          entries.merge!({'mobile' => pn.value})
        when 'Fax'
          entries.merge!({'facsimileTelephoneNumber' => pn.value})
      end
    end
    entries
  end
  
  def emails_to_ldap
    entries = {'mail' => [primary_email.blank? ? '' : primary_email.value]}#(emails.count == 0 ? [''] : emails.map {|e| e.value }) }
  end
  
  def set_primary_plural(obj, collection)
    # Sync is setting value to nil if email is removed from phone
    if obj.nil?
      old_primary = primary_or_first(collection)
      old_primary.delete if old_primary
    else
      collection.each { |plural| plural.primary = (plural.value == obj.value) }
      collection.concat(obj) unless collection.include?(obj)
      obj.primary = true
    end
  end
       
  def split_display_name
    return unless @given_name.blank? and @family_name.blank? and !display_name.blank? 
    self.given_name, self.family_name = display_name.split(' ', 2)
  end
  
  def create_uuid
    self.uuid =  UUIDTools::UUID.random_create.to_s if self.uuid.blank?
  end
  
  def display_name
    self[:display_name] ? super : ""
  end
  
  def primary_or_first(collection)
    default = collection.primary.first
    if default.nil?
      default = collection.first
    end
    default
  end
  
  def is_owner?(p)
    self.owner == p
  end
  
  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "120x120", :name => "medium"},
      :small => {:crop => "1:1", :size => "32x32", :name => "small"},
      :tiny => { :crop => "1:1", :size => "17x17" , :name => "tiny" },
      :iphone => {:crop => "1:1", :size => "62x62", :name => "iphone" }
    }
  }
  
  validates_file_format_of :icon, :in => ["gif", "jpg"]
  validates_filesize_of :icon, :in => 1.kilobytes..5000.kilobytes
  
end
