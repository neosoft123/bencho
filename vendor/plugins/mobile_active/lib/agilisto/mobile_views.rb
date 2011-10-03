module Agilisto
  module MobileViews
    
    def mobile?
      @wurfl_device && @wurfl_device.is_wireless_device?
    end
        
    def method_missing sym, *args, &block
      if @wurfl_device && @wurfl_device.respond_to?(sym)
        if mobile?
          @wurfl_device.send(sym, *args, &block)
        else
          true
        end
      else
        super
      end
    end
    
  end 
end 
