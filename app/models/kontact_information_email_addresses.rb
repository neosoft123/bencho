class KontactInformation
  
  has_many :emails, :uniq => true, :dependent => :destroy
  
  attr_accessor :primary_email
  
  after_save :save_emails
  validates_associated :emails
  
  def email
    primary_email
  end
  
  def primary_email
    primary_or_first(self.emails)
  end
  
  def primary_email=(email)
    email = if email.is_a?(String)
      if self.emails.exists?(:value => email)
        self.emails.find_by_value(email)
      else
        Email.new(:value => email, :kontact_information_id => self.id, :primary => true)
      end
    else
      email
    end
    
    set_primary_plural(email, emails)
  end
  
  def save_emails
    emails.each do |email|
      email.save(false)
    end
  end
  
  def inplace_email
    self.primary_email ? self.primary_email : self.build_inplace_primary_email
  end
  
  def build_inplace_primary_email
    e = Email.new( { :field_type => "Email", :value => "" , :primary => true  , :kontact_information_id => self.id } )
    e.save(false)
    e
  end
  
  def existing_email_attributes=(email_attributes)
    emails.reject(&:new_record?).each do |email|
      attributes = email_attributes[email.id.to_s]
      if attributes
        email.attributes = attributes
      else
        emails.delete(email)
      end
    end
  end
  
end