# require File.join( RAILS_ROOT, 'lib', 'soap', 'sts' , 'SmsWSClient')
# 
# class SmsWorker < Workling::Base
#   
#   def send_sms(options)
#     
#     logger.debug 'Sending SMS from worker'
#     
#     profile = options[:profile]
#     message = options[:message]
#     
#     sms = SmsWSClient.new
#     if sms.send_sms(profile.kontact_information.mobile, message)
#       logger.info "Mobilised: Welcome sms sent to " + profile.kontact_information.mobile
#     else
#       logger.info "Mobilised: failed sending sms"
#     end    
#     
#   end
#   
# end