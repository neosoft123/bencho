# # Extension to Mobilized Styles to allow for the creation of browser specific script extensions
# 
# module MobilizedScripts
#   
#   def javascript_include_tag_with_mobilization(*sources)
#     mobilized_sources = Array.new
#     sources.each do |source|
#       subbed_source = source.to_s.gsub(".js","")
# 
#       possible_sources = ["#{subbed_source.to_s}_#{user_agent_device_name}"]
# 
#       mobilized_sources << source
# 
#       for possible_source in possible_sources
#         path = File.join(ActionView::Helpers::AssetTagHelper::JAVASCRIPTS_DIR,"#{possible_source}.js")
#         mobilized_sources << possible_source if File.exist?(path)
#       end
#     end
# 
#     javascript_include_tag_without_mobilization(*mobilized_sources)
#     
#   end
# end
# 
# # Monkey patch MobileFu to allow for javascript mime-type to bypass the set_mobile code
# require 'mobile_fu'
#   
# module ActionController
#   module MobileFu
#       module InstanceMethods
#         def set_mobile_format
#            if is_mobile_device?
#              request.format = session[:mobile_view] == false ? :html : :mobile unless request.format == :js
#              session[:mobile_view] = true if session[:mobile_view].nil?
#            end
#          end
#        end
#     end
# end
# 
# ActionView::Base.send(:include, MobilizedScripts)
# ActionView::Base.send(:alias_method_chain, :javascript_include_tag, :mobilization)