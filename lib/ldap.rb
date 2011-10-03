LDAP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/ldap.yml")[RAILS_ENV]

module LDAP

  #Bind with the main credential and query the full DN of the email address
  #given to us as a parameter, then unbind and rebind as the user.
  #
  #If login succeeds return an LDAPUser object
  #If login fails return false
  def self.authenticate(identifier,password)
    if identifier.to_s.length > 0 and password.to_s.length > 0
      ldap_con = initialize_ldap_con
      user_filter = Net::LDAP::Filter.eq("username", identifier )
      if rs = ldap_con.bind_as(:filter => user_filter, :password => password)
        return User.new(:identifier, groups, self)
      else
        return false
      end
    end
  end
 
  private
 
  def self.initialize_ldap_con
    hsh = {:host => LDAP_CONFIG["ldap_server"], :port => LDAP_CONFIG["ldap_port"]}
    hsh[:base] = LDAP_CONFIG["ldap_tree_base"]
    hsh[:auth] = { :method => :simple, :username => LDAP_CONFIG["ldap_username"], :password => LDAP_CONFIG["ldap_password"] }
    Net::LDAP.new( hsh )
  end
 
  #takes a DN and derives the name of the group from it
  #returns name of group (in lower case)
  def self.derive_group(dn, group_identifier_attribute_type)
   first_ou = dn.downcase.match(/,#{group_identifier_attribute_type.downcase}=[^,]+/).to_s
   group = first_ou[group_identifier_attribute_type.length+2,first_ou.length]
  end

end