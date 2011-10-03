class Device < ActiveRecord::Base
  
  has_many :device_attributes, :dependent => :destroy
    
  def [](name)
    self.device_attributes.find_by_name(name.to_s).value rescue nil
  end
  
  def is_mobile?
    self[:mobileDevice] == "1"
  end
  
  def force_mobile
    self.device_attributes.find_by_name("mobileDevice").update_attribute(:value, true)
  rescue
    self.device_attributes.create(:name => "mobileDevice", :value => true)
  end
  
  def low?
    stylesheet_level == "low"
  end
  
  def mid?
    stylesheet_level == "mid"
  end
  
  def high?
    stylesheet_level == "high"
  end
    
end
