class Profile < ActiveRecord::Base
  
  # acts_as_cached
  unloadable  
  include Locationised

  has_business_card
  
  concerned_with :friends, :followers, :mobile, :dating
  
  delegate :online?, :to => :user
  
  belongs_to :user
  has_one :wallet
  
  acts_as_mappable
  
  has_many :chat_invitations, :foreign_key => :to_id
  
  has_and_belongs_to_many :groups
  has_many :owned_groups, :class_name => 'Group', :foreign_key => 'owner_id'
  
  # TODO this feels like a hack .. need it to make shared group contacts work .. review
  def shared_contacts
    if @shared_contacts.nil?
      @shared_contacts = []
      groups.each do |g|
        @shared_contacts.concat(g.kontacts.map{|k|k.ki.owner == self ? nil : k}.compact)
      end
      @shared_contacts.uniq!
    end
    @shared_contacts
  end
  
  def shared_contacts_count
    shared_contacts.length
  end
  
  has_many :invitations

  # -- contacts ----------------------------------------------------------------------------------------------
  
  has_many :kontacts, :dependent => :destroy, :as => :parent  do
    def own
      first :conditions => ['status = "own"']
    end
  end
  has_many :kontact_informations, :through => :kontacts, :uniq => true, :include => [:phone_numbers, :emails]
    
  def sort_contacts_first_last
    self.update_attribute(:sort_contacts_last_name_first, false)
  end
  
  def sort_contacts_last_first
    self.update_attribute(:sort_contacts_last_name_first, true)
  end

  # ----------------------------------------------------------------------------------------------------------

  
  has_many :locations, :dependent => :destroy, :order => 'created_at desc' do
    def current
      find :first
    end
    def last_5
      find :all, :limit => 5
    end
  end
  
  has_many :text_messages, :dependent => :destroy
  
  def location
    self.locations.current
  end
  
  def has_location?
    self.locations.size > 0
  end
    
=begin
  TODO move is_Active to user
  rename it to active
=end
  attr_protected :is_active

  #  attr_immutable :id
  
  #  validates_format_of :email, :with => /^([^@\s]{1}+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message=>'does not look like an email address.'
 #  validates_length_of :email, :within => 3..100
  # validates_uniqueness_of :email, :case_sensitive => false
  # validates_presence_of :gender
  # validates_presence_of :given_name
  # validates_presence_of :display_name
  # validates_presence_of :interest
  # validates_presence_of :description
  # validates_presence_of :relation_status
   
  # Feeds
  has_many :feeds, :dependent => :destroy
  has_many :feed_items, :through => :feeds, :order => 'created_at desc'
  has_many :private_feed_items, :through => :feeds, :source => :feed_item, :conditions => {:is_public => false}, :order => 'created_at desc'
  has_many :public_feed_items, :through => :feeds, :source => :feed_item, :conditions => {:is_public => true}, :order => 'created_at desc'
  
  # Messages
  has_many :sent_messages,     :class_name => 'Message', :order => 'created_at desc', :foreign_key => 'sender_id', :as => :sender, :dependent => :destroy
  has_many :received_messages, :class_name => 'Message', :order => 'created_at desc', :foreign_key => 'receiver_id', :as => :receiver, :dependent => :destroy
  has_many :unread_messages,   :class_name => 'Message', :conditions => {:read => false}, :foreign_key => 'receiver_id', :as => :receiver
  
  # Comments and Blogs
  has_many :comments, :as => :commentable, :order => 'created_at desc', :dependent => :destroy
  has_many :blogs, :order => 'created_at desc', :dependent => :destroy
  
  
  # Photos
  has_many :photos, :order => 'created_at DESC', :dependent => :destroy
  
  #Forums
  has_many :forum_posts, :foreign_key => 'owner_id', :dependent => :destroy

  # Profile Statuses
  has_many :profile_statuses, :dependent => :destroy, :order => 'created_at desc' do
    def current
      find :first
    end
  end
    
  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"},
      :iphone => {:crop => "1:1", :size => "62x62", :name => "iphone"}
    }
  }
  
  def is_complete?
    !(self.display_name.blank? && (self.family_name.blank? || self.given_name.blank?) &&
      (self.gender.blank? ||
      self.mobile.blank? || 
      self.email.blank? ||
      self.birthday.blank? ||
      self.icon.blank?))
  end
  
  def give_completion_bonus!
    return if self.completion_bonus_awarded?
    transaction do
      service = Service.first(:conditions => {:active => true, :credit => 500})
      self.wallet.buy_smartbucks(service, true).success
      self.update_attribute(:completion_bonus_awarded, true)
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
        self.user.login
      end
    end
  end
  
  alias_method :f, :formatted_name
  alias_method :full_name, :formatted_name
  
  cattr_accessor :featured_profile
  @@featured_profile = {:date=>Date.today-4, :profile=>nil}


  def self.latest_profiles(page = 1, per_page = 5)
    Profile.paginate(:all, :order => "created_at DESC",
      :page => page, :per_page => per_page)
  end


  def self.popular_profiles(page = 1, per_page = 5)
    Profile.find(:all).sort {|b,a| a.followers_count <=> b.followers_count }.paginate(:page => page, :per_page => per_page)
  end

  def self.featured
    find_options = {
      :include => :user,
      :conditions => ["is_active = ? and user_id is not null", true],
    }
    # find(:first, find_options.merge(:offset => rand( count(find_options) - 1)))
    find(:first, find_options.merge(:offset => rand(count(find_options)).floor)) 
  end  
  
  def self.search query = '', options = {}
    query ||= ''
    q = '*' + query.gsub(/[^\w\s-]/, '').gsub(' ', '* *') + '*'
    # options.each {|key, value| q += " #{key}:#{value}"}
    options.each {|key, value| q += " #{key}:#{value}"}
    arr = Profile.find(:all)
    logger.debug arr.inspect
    search_privacy_filter(arr)
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
  
  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "120x120", :name => "medium"},
      :small => {:crop => "1:1", :size => "32x32", :name => "small"},
      :tiny => { :crop => "1:1", :size => "17x17" , :name => "tiny" },
      :iphone => {:crop => "1:1", :size => "62x62", :name => "iphone" }
    }
  }

  # Callbacks
  def after_create
    #create_empty_kontact_information
  end
  
  def before_create
    self.is_active = true
  end
      
  def mobile_activation_code
    self.user.mobile_activation_code
  end
  
  def mobile_activated?
    self.user.mobile_activation_code.nil?
  end

  def to_param
    "#{user.login}"
  end
    
  def has_network?
    !Friend.find(:first, :conditions => ["invited_id = ? or inviter_id = ?", id, id]).blank?
  end
    
  def no_data?
    (created_at <=> updated_at) == 0
  end

  def has_wall_with profile
    return false if profile.blank?
    !Comment.between_profiles(self, profile).empty?
  end
  
  # Kontacts Methods
  
  def owner_of?(kontact_information)
    self.kontacts.own.count(:conditions => {:kontact_information_id => kontact_information}) > 0
  end
  
  def can_send_messages
    user.can_send_messages
  end
  
  #TODO: Just returning login values for now until profile merge complete
  def to_ldap_entry
  	{	
  		"objectclass"     => ["top", "person", "organizationalPerson", "inetOrgPerson", "mozillaOrgPerson"],
  		"ou"              => "friends",
  		"sn"              => self.family_name,
  		"cn"             =>  self.formatted_name,
  		"uid"             => self.user.login,
  		"fn"              => self.given_name,
  		"givenName"       => self.given_name
  	}
  end
  
  protected
  def fix_http str
    return '' if str.blank?
    str.starts_with?('http') ? str : "http://#{str}"
  end
  
  private
  
end
