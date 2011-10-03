class InternationalDialingCode < ActiveRecord::Base
  
  validates_presence_of :code
  validates_presence_of :country
  
  def self.find_for_mobile_number mobile
    InternationalDialingCode.all.each do |idc|
      return idc if mobile =~ Regexp.new("^\\+*#{idc.code}")
    end
    nil
  end
  
end
