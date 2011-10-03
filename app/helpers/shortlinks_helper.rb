module ShortlinksHelper
  
  def linkify text
    match = text.scan Shortlink::REGEX
    match.each do |m|
      text = text.gsub(m[0], link_to(m[0], m[0]))
    end if match
    text
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
