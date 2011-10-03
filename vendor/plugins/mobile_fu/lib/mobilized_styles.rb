# Copyright (c) 2008 Brendan G. Lim (brendan@intridea.com)
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module MobilizedStyles
  
  # This logic was taken from Michael Bleigh's browserized styles
  # with modification to work for mobile browsers.
  
  def user_agent_device_name
    @user_agent_device_name ||= begin
      
      ua = request.user_agent
      return nil if ua.nil?
      ua.downcase!
      if ua.index('mobileexplorer') || ua.index('windows ce')
        'mobileexplorer'
      elsif ua.index('blackberry') 
        'blackberry'
      elsif ua.index('iphone') || ua.index('ipod')
        'iphone'
      elsif ua.index('nokia') 
        'nokia'
      elsif ua.index('palm') 
        'palm'
      end
    end
  end

  def stylesheet_link_tag_with_mobilization(*sources)
    if (@device && @device.is_mobile?) or (session[:force_agent] == :mobile)
      new_sources = []
      sources.each do |source|
        source = source.to_s.gsub('.css', '')
        level = @device.stylesheet_level rescue nil
        level ||= 'low'
        new_source = "#{source}_#{level}"
        path = File.join(ActionView::Helpers::AssetTagHelper::STYLESHEETS_DIR,"#{new_source}.css")
        sass_path = File.join(ActionView::Helpers::AssetTagHelper::STYLESHEETS_DIR,"sass","#{new_source}.sass")
        new_sources << new_source if File.exist?(path) || File.exist?(sass_path)
      end
      stylesheet_link_tag_without_mobilization(*new_sources)
    else
      stylesheet_link_tag_without_mobilization(*sources)
    end
  end
  
  # TODO kept for reference purposes
  def stylesheet_link_tag_with_mobilization_old(*sources)
    mobilized_sources = []
    sources.each do |source|
      subbed_source = source.to_s.gsub('.css','')
      possible_sources = ["#{subbed_source.to_s}_#{user_agent_device_name}"]
      mobilized_sources << source

      for possible_source in possible_sources
        path = File.join(ActionView::Helpers::AssetTagHelper::STYLESHEETS_DIR,"#{possible_source}.css")
        sass_path = File.join(ActionView::Helpers::AssetTagHelper::STYLESHEETS_DIR,"sass","#{possible_source}.sass")
        mobilized_sources << possible_source if File.exist?(path) || File.exist?(sass_path)
      end
    end

    stylesheet_link_tag_without_mobilization(*mobilized_sources)
  end
end