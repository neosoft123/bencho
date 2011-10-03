require File.join(RAILS_ROOT, 'lib', 'soap', 'sts' , 'SmsWSClient')

class WapLinkJob < Struct.new(:message_id)
    def perform
        message = TextMessage.find(message_id)
        RAILS_DEFAULT_LOGGER.debug "Sending #{message.message} to #{message.to}"
        sms = SmsWSClient.new
        if sms.send_wap_link(message.to, message.href, message.message)
          message.sent = true
          message.save!
          message.bill!
          RAILS_DEFAULT_LOGGER.debug "Sent SMS"
        else
          RAILS_DEFAULT_LOGGER.debug "Failed SMS"
        end
        true
      rescue => e
        RAILS_DEFAULT_LOGGER.error "SmsJob: " + e.to_s
        false
      end    
end