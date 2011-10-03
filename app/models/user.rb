require 'digest/sha1'
require 'openssl'

class User < ActiveRecord::Base
  
  # acts_as_cached
  unloadable
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles
  
  # concerned_with :chatter
  
  include Chatter
  can_chat
  
  # chatter status overrides
  def away(message=nil)
    if self.profile.profile_statuses.length > 0
      super(self.profile.profile_statuses.current.text)
    else
      super(nil)
    end
  end
  
  def available(message=nil)
    if self.profile.profile_statuses.length > 0
      super(self.profile.profile_statuses.current.text)
    else
      super(nil)
    end
  end
  
  # class << self
  #   def create_help_user
  #     transaction do 
  #       help = User.new(:login => "help", :password => "agilisto")
  #       help.save!
  #       help.register!
  #       help.activate
  #       help.profile.update_attribute(:display_name, "Online Help")
  #       help
  #     end
  #   end
  # end
    
  def update_locations_from_fireeagle
    User.transaction do
      # last_loc = self.profile.locations.current
      # self.fireeagle.user.locations.each do |loc|
      #   if loc.located_at > last_loc.created_at
      #     location = self.profile.locations.create!(
      #       :title => loc.name,
      #       :created_at => loc.located_at,
      #       :latitude => loc.geo.upper_corner.x,
      #       :longitude => loc.geo.upper_corner.y
      #     )
      #   end
      # end
      if self.settings.location and self.settings.location.located_at > self.profile.locations.current.created_at
        begin
        self.profile.locations.create!(
          :title => self.settings.location.name,
          :created_at => self.settings.location.located_at,
          :latitude => self.settings.location.geo.upper_corner.x,
          :longitude => self.settings.location.geo.upper_corner.y
        )
        rescue => e
          RAILS_DEFAULT_LOGGER.debug "Error getting data from Fire Eagle: #{e}"
          # notify_hoptoad(e)
        end
      end
    end
  end
    
  has_one :settings, :dependent => :destroy
  has_one :profile, :dependent => :destroy
  has_one :ki, :class_name => :kontact_information, :through => :profile
  
  has_many :client_applications
  has_many :tokens, :class_name=>"OauthToken",:order=>"authorized_at desc",:include=>[:client_application]

  attr_accessor :email, :terms_of_service
  attr_protected :is_admin, :can_send_messages
  
  # dummy field for holding mobile number during sign-up
  attr_accessor :mobile_number
  
  #attr_immutable :id
  
  delegate :has_facebook_login?, :to => :settings
  delegate :has_twitter_login?, :to => :settings
  
  validates_presence_of :login
  validates_length_of :login, :within => 3..40
  validates_uniqueness_of :login, :case_sensitive => false, :on => :create
#  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message,  :on => :create
  validates_acceptance_of :terms_of_service, :on => :create, :allow_nil => false
  validates_format_of :login, :with => /^[a-zA-Z0-9\_]*?$/, :message => 'accepts only letters, 0-9, and underscore'

  before_save :encrypt_password
  # validates_less_reverse_captcha
  before_create :set_sync_reminder_date
  after_create :create_profile, :create_settings

  # Tender App SSO
  def tender_token(expires)
    method = OpenSSL::Digest::Digest.new("SHA1")
    string = "support.dev.7.am/#{email}/#{expires}"
    OpenSSL::HMAC.hexdigest(method, TENDER_SECRET, string)
  end
  
  
  def create_profile
    self.profile = Profile.create(:is_active => true, :user => self)
    self.profile.wallet = Wallet.new(:profile => self.profile, :balance => 0)
    self.profile.wallet.save!
    #AccountMailer.deliver_signup(self.reload)
  end
  
  def create_settings
    self.settings = Settings.create(:user => self)
  end

  def sync_started
    self.last_sync_started = DateTime.now
    save!
  end
  
  def sync_finished
    self.last_sync_finished = DateTime.now
    save!
  end
  
  def remind_me_to_sync?
    if remind_to_sync_date.nil? or (DateTime.now > remind_to_sync_date)
      return true if last_sync_finished.nil?
      return true if (DateTime.now - 2.weeks) > last_sync_finished
    end
    
    return false
  end
  
  def f
    profile.f
  end
  
  def can_mail? user
    can_send_messages? && profile.is_active?
  end

  # Username or email login for restful_authentication 
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => ["login = ?", login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_me
    self.remember_token_expires_at = 10.years.from_now
    self.remember_token = UUID.random_create.to_s + '-' + UUID.random_create.to_s if self.remember_token.nil?
    save false
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end
  
  # def forgot_password
  #   @forgot = true
  #   self.password = UUID.random_create.to_s[0,8]
  #   self.password_reminder = true
  #   #self.password_confirmation = password
  #   encrypt_password
  #   save!
  #   self.password
  # end
  
  def change_password(current_password, new_password, confirm_password, check_old_password = true)
    sp = User.encrypt(current_password, self.salt)
    if check_old_password
      errors.add( :password, "The password you supplied is not the correct password.") and
        return false unless sp == self.crypted_password
    end
    errors.add( :password, "The new password does not match the confirmation password.") and
      return false unless new_password == confirm_password
    errors.add( :password, "The new password may not be blank.") and
      return false if new_password.blank?
    
    self.password = new_password
    self.password_reminder = false
    #self.password_confirmation = confirm_password
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") 
    self.crypted_password = encrypt(new_password)
    save
  end
  
  # RESTFul Authentication
  # Activates the user in the database.
   def activate
     @activated = true
     self.activated_at = Time.now.utc
     self.activation_code = nil
     self.activate!
     save!
   end
   
   def confirm_mobile
     self.update_attributes( { :mobile_activation_code => nil , :mobile_activated_at => Time.now.utc } )
   end

   # Returns true if the user has just been activated.
   def recently_activated?
     @activated
   end

   def active?
     # the existence of an activation code means they have not activated yet
     activation_code.nil?
   end
   
   def login=(value)
     write_attribute :login, (value ? value.to_s.downcase : nil)
   end

   def make_activation_code
     self.deleted_at = nil
     self.activation_code = self.class.make_token
   end
 
   def make_mobile_activation_code
     uuid = UUID.random_create.to_s[0..7]
     self.update_attribute(:mobile_activation_code , uuid)
     uuid
   end
   
   # Can impersonate users
   def ldap_admin?
     login == 'ldapadmin'
   end

  def to_ldap_entry
  	{	
  		"objectclass"     => ["top", "person", "organizationalPerson", "inetOrgPerson", "mozillaOrgPerson"],
  		"ou"              => "users",
  		"uid"             => "#{self.login}",
      "cn"              => "#{self.login}",
  		"mobile"          => "#{self.profile.mobile}",
  		"location"        => "#{self.profile.location}",
  		"displayName"     => "#{self.profile.formatted_name}",
  		"mail"            => "#{self.profile.email}"
  	}
  end
  
  def ldap_search(conditions)
    self.profile.kontact_informations.find(:all, :conditions => conditions, :include => [:phone_numbers, :emails])
  end
  
  # Ejabberd Search
  def ldap_people_search(conditions)
    User.find(:all, :conditions => conditions)
  end
  
  # Ejabberd Friend Roster
  def friend_search(conditions)
    profile = User.find(:first, :conditions => conditions).profile rescue nil
    return [] if profile.nil?
    profile.friends
  end
  
  # Openfire user search
  def user_search(conditions)
    User.find(:all, :conditions => conditions)
  end

protected
  
  def set_sync_reminder_date
    self.remind_to_sync_date = DateTime.now
  end
  
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if
      new_record? || @forgot
    self.crypted_password = encrypt(password)
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end

end
