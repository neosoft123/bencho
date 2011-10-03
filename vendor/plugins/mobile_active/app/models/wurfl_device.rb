class WurflDevice < ActiveRecord::Base

  has_many :wurfl_capabilities, :dependent => :destroy

  # attr_accessor :user_agent
  attr_accessor :capability_summary

  def build_capability_lookup
    @capability_summary ||= {}
    @user_agent = self.xml_id if @user_agent.blank?
    self.wurfl_capabilities.map { |c| @capability_summary[c.name.to_sym] = c.value if !@capability_summary[c.name.to_sym]}
    if fall_back != 'root'
      parent = WurflDevice.find_by_xml_id(fall_back, :include => :wurfl_capabilities)
      self.capability_summary.reverse_merge!(parent.build_capability_lookup) if parent
    end
    return @capability_summary
  end

  def capability(name)
    cap = @capability_summary[name.to_sym]
    return type_conversion(cap) if cap
  end
  
  def set_capability(name, value)
    @capability_summary[name.to_sym] = value.to_s
  end
  
  def supports_external_css?
    [:high, :mid].include?(xhtml_support_level)
  end
  
  def supports_css?
    [:low, :mid, :high].include?(xhtml_support_level)
  end
  
  def supported_device?
    xhtml_support_level != :none
  end
  
  def xhtml_support_level
    case self.capability(:xhtml_support_level)
    when -1
      # no XHTML support at all
      return :none
    when 0
      # basic XHTML, no CSS support
      return :basic
    when 1
      # basic XHTML, some CSS support
      return :low
    when 2
      # much the same as 1, some grey area
      return :low
    when 3
      # Full XHTML with excellent CSS support
      return :mid
    when 4
      # Awesomeness, iPhone and so on
      return :high
    end
  end
  
  def low?
    [:none, :basic, :low].include?(xhtml_support_level)
  end
  
  def supports_javascript?
    capability(:ajax_support_javascript)
  end
    
  def supports_javascript_css_manipulation?
    capability(:ajax_manipulate_css)
  end
  
  def supports_ajax?
    capability(:ajax_xhr_type) != 'none'
  end
  
  def supports_j2me_midp_1_0?
    capability(:j2me_midp_1_0) != 'none'
  end
  
  def supports_j2me_cldc_1_0?
    capability(:j2me_cldc_1_0) != 'none'
  end
  
  def supports_j2me_midp_2_0?
    capability(:j2me_midp_2_0) != 'none'
  end
  
  def supports_j2me_cldc_1_1?
    capability(:j2me_cldc_1_1) != 'none'
  end
  
  def is_wireless_device?
    capability(:is_wireless_device)
  end
  
  # TODO remove, this is lame
  def browser_is_wap?
    capability(:is_wireless_device)
  end

  def brand
    capability(:brand_name)
  end

  def model
    capability(:model_name)
  end

  def check_is_desktop( user_agent )
    return true if user_agent.empty?
    if @user_agent.index('Opera') || @user_agent.index('Firefox') || @user_agent.index('Safari')
      return true if @user_agent.index('Windows') ||
        @user_agent.index('Linux') ||
        @user_agent.index('Macintosh')
    end
    if @user_agent.index('MSIE 6') or @user_agent.index( 'MSIE 5' )
      if (not @user_agent.index('MIDP')) and
          (not @user_agent.index('Windows CE')) and
          (not @user_agent.index('Symbian'))
        return true
      end
    end
  end

  def find_by_user_agent( ua )
    ua ||= ''
    @user_agent = ua.dup
    @user_agent.sub!( /UP.Link.*/, '' )
    @user_agent.strip!

    if check_is_desktop( @user_agent )
      return nil
    end

    # if we find exactly the @user_agent we're looking for, fantastic, return
    # the device for that.  If not start looking for the longest matching
    # substring.
    dev = WurflDevice.find( :first,
      :conditions => ['user_agent = ?', @user_agent], :include => :wurfl_capabilities )
    if dev
      return dev
    end

    short_ua = @user_agent[0,4]
    if WurflDevice.count( :conditions => ['user_agent like :short_ua', {:short_ua => short_ua + '%'}] ) == 0
      return nil
    end

    search_ua = @user_agent
    while search_ua.length > 4
      dev = WurflDevice.find( :first,
        :conditions => ['user_agent like :search_ua', {:search_ua =>
              search_ua + '%'}], :include => :wurfl_capabilities )
      if dev
        return dev
      end

      search_ua.chop!
    end

    return nil
  end

  private
  # lifted this from the other ruby tools for WURFL, seemed like a good idea
  def type_conversion( value )
    res = nil
    case value.strip
    when /^\d+$/
      res = value.to_i
    when /^true$/i
      res = true
    when /^false$/i
      res = false
    else
      # don't stip, because user may want the blank space.
      res = value
    end
    res
  end
end
