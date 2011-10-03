class Crumb
  include ActionView::Helpers
  
  def initialize(link_text, url = nil)
    @link_text = link_text
    @url = url
  end
  
  def to_s
    return link_to(h(@link_text), @url) unless @url.blank?
    return h(@link_text)
  end
  
end
