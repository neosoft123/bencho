# Author: Casper Peter Lotter
module Privatised  
 
  module Profile
    def self.included(base)
      base.extend ClassMethods
    end
  
    module ClassMethods
      
      # Filter the search array based on each individual privacy setting
      def search_privacy_filter(arr)
        peeping_tom = KontactContext().profile
        return arr unless peeping_tom
        arr.select do |e|
          ps = e.kontact_information.privacy_setting('search')
          flag = true
          case ps
          when 'me'
            flag = false
          when 'friends'
            peeping_tom.friend_of?(e) ? ( flag = true ) : ( flag = false )
          end
          flag
        end
      end
    end
    
    # instance methods
    def show_location_map?
      # TODO fix this
      #self.kontact_information.location != PrivateColumn.new
    end
  end
  
  CONTACT_COLUMNS = [ :email , :emails , :phone_numbers , :primary_phone_number , :primary_email ]
  ADDITIONAL_COLUMNS = [ :gender , :birthday , :location , :about_me ]
  COLUMNS = CONTACT_COLUMNS + ADDITIONAL_COLUMNS  

  def privacy_setting=(hash)
    raise OptionParser::InvalidOption unless PrivacySetting::TYPES.include?(hash[:type])
    
    ps = self.privacy_selector(hash[:type])
    unless ps.blank?
      ps.update_attribute(:value , hash[:value]) 
    else 
      self.privacy_settings.create( { :field_type => hash[:type].to_s.downcase ,
                                      :value => hash[:value] } ) 
    end 
  end
  
  # return the privacy setting value or object
  def privacy_setting(privacy_type , object = false)
    ps = self.privacy_selector(privacy_type)
    ps.blank? ? nil : ( object ? ps : ps.value )
  end
  
  def privacy_setting?(privacy_type , setting)
    ps = privacy_setting(privacy_type)
    case setting
    when "me"
      ps.blank? ?  true :  ( setting == ps ) 
    when "friends"
      ps.blank? ?  false : ( setting == ps )
    when "everyone"
      ps.blank? ? false : ( setting == ps )
    end
  end
  
  def cascade_privacy_setting?(privacy_type , setting)
    ps = privacy_setting(privacy_type)
    case setting
    when "me"
      ps.blank? ?  true : ( ( ps == "everyone" || ps == "friends" ) ? true : ( setting == ps ) )
    when "friends"
      ps.blank? ?  false : ( (ps == "everyone") ? true : ( setting == ps ) )
    when "everyone"
      ps.blank? ?  false : ( setting == ps )
    end
  end
  
  def privatised_emails
    PrivateEmail.new
  end

  def privatised_phone_numbers
    PrivatePhoneNumber.new
  end
  
  def privatised_column
    PrivateColumn.new
  end

  # overide methods on the specific object that the peeping tom should not see
  def privacy_filter(peeping_tom)
    arr_cols = [ :emails , :phone_numbers ]
    COLUMNS.each do |m|
      collection = arr_cols.include?(m) ? self.send(m) : nil
      privacy_data_type = privacy_information_type_selector(m)
      self.create_method(m) do
        case self.privacy_setting(privacy_data_type)
        when "everyone"
          collection || super
        when "friends"
          self.owner.friend_of?(peeping_tom) ? super : ( collection ? self.send('privatised_' + m.to_s) : privatised_column  ) 
        else
          collection ? ( self.send('privatised_' + m.to_s) ) : privatised_column
        end
      end
    end
  end
  
  def apply_filters(peeping_tom = nil)
    profile = peeping_tom || KontactContext().profile
    RAILS_DEFAULT_LOGGER.debug "SSKJHJKHAGSKJHGJKH #{self.inspect}"
    return if profile.nil? or ( profile == self.owner )
    privacy_filter(profile)
  end
 
  def after_find
    apply_filters
  end
  
  protected
    
  def privacy_selector(privacy_type)
    case privacy_type
    when "search"
      self.privacy_settings.basic.first
    when "contact"
      self.privacy_settings.contact.first
    when "additional"
      self.privacy_settings.additional.first
    end
  end
  
  def privacy_information_type_selector(column)
    return 'contact' if CONTACT_COLUMNS.include?(column)
    return 'additional' if ADDITIONAL_COLUMNS.include?(column)
    raise "Privatised: Unknown column name"
  end
 
  # create singleton methods
  def create_method(name, &block)
    metaclass = class << self; self; end
    metaclass.send(:define_method, name, &block)
  end

end