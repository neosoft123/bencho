module Agilisto 
  module MobileActive 
    
    def self.included(base) 
      base.extend ActMethods
    end 
    
    module ActMethods 
      def acts_as_mobile(opts={})
        $force_mobile = opts.has_key?(:force_mobile) ? opts.delete(:force_mobile) : false
        unless included_modules.include? InstanceMethods 
          extend ClassMethods
          prepend_before_filter :set_mobile_format
          include InstanceMethods
        end 
      end 
    end 
    
    module ClassMethods 
    end 
    
    module InstanceMethods
      
      def is_mobile_device?
        find_device unless @wurfl_device && @device
        @wurfl_device && @wurfl_device.is_wireless_device?
      end

      protected
      
      def set_mobile_format
        find_device unless @wurfl_device || request.format == :xml
        request.format = :mobile if @wurfl_device && @wurfl_device.is_wireless_device? && request.format != :js
      end
      
      def find_device user_agent=nil
        
        user_agent ||= request.user_agent
        cache_key = Digest::SHA1.hexdigest(user_agent)
        RAILS_DEFAULT_LOGGER.debug "Loading WURFL device for: #{user_agent}"
        
        @device = @wurfl_device = Rails.cache.fetch(cache_key) do
          device = WurflDevice.new.find_by_user_agent(user_agent)
          device.build_capability_lookup if device
        
          if !device && $force_mobile && request.format != :xml
            # device = WurflDevice.first(:conditions => {:xml_id => "apple_generic"})
            device = WurflDevice.first(:conditions => {:xml_id => "generic"})
            device.build_capability_lookup if device
            if RAILS_ENV == "development"
              device.set_capability(:xhtml_support_level, 4)
              device.set_capability(:ajax_support_javascript, true)
              device.set_capability(:ajax_manipulate_css, true)
            end
          end

          if device && !device.is_wireless_device? && $force_mobile && request.format != :xml
            # device = WurflDevice.first(:conditions => {:xml_id => "apple_generic"})
            device = WurflDevice.first(:conditions => {:xml_id => "generic"})
            device.build_capability_lookup if device
            if RAILS_ENV == "development"
              device.set_capability(:xhtml_support_level, 4)
              device.set_capability(:ajax_support_javascript, true)
              device.set_capability(:ajax_manipulate_css, true)
            end
          end
          
          device               
        end
        
        if @wurfl_device.nil?
          RAILS_DEFAULT_LOGGER.debug "NB. No WURFL device found!"
        else 
          RAILS_DEFAULT_LOGGER.debug "WURLF device: #{@wurfl_device.xml_id}"
        end
        
      end
      
    end
    
    
  end 
end 
