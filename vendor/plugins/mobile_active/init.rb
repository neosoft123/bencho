%w(wurfl_capability wurfl_device).each { |f| require File.join(File.dirname(__FILE__), "app/models/#{f}") }
require File.dirname(__FILE__) + "/lib/mobile_style_handler"
ActionController::Base.send(:include, Agilisto::MobileActive) 
ActionController::Base.helper(Agilisto::MobileViews) 
ActionView::Base.send(:include, Agilisto::MobileStyleHandler)
ActionView::Base.send(:alias_method_chain, :stylesheet_link_tag, :mobilization)
WurflDevice.class_eval "alias_method :is_mobile?, :is_wireless_device?"
WurflDevice.class_eval "alias_method :stylesheet_level, :xhtml_support_level"
WurflDevice.class_eval "alias_method :level, :xhtml_support_level"

