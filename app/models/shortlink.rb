include ActionController::UrlWriter

class Shortlink < ActiveRecord::Base
  
  validates_presence_of :href
  after_create :generate_short_href
  
  # REGEX = /((https?:\/\/|www\.)[\w\d\.\/:-]+)/i
  REGEX = /((https?:\/\/|www\.)[\w\d\.\/:-?&]+)/i
  
  class << self
            
    def create_or_find_shortlink href
      shortlink = Shortlink.find_by_href(href)
      shortlink = Shortlink.create(:href => href) unless shortlink
      shortlink
    end
    
    def shortlinkify text
      match = text.scan Shortlink::REGEX
      match.each do |m|
        shortlink = Shortlink.create_or_find_shortlink(m[0])
        link = linky_url(shortlink.href_code)
        text = text.gsub(m[0], link)
      end if match
      text
    end
        
  end
  
  def generate_short_href
    self.update_attribute(:href_code, id.to_s(36))
  end
  
  def redirect_href
    (href =~ /^https?:\/\//i) ? href : "http://#{href}" 
  end
  
end
