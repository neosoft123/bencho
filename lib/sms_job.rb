require File.join(RAILS_ROOT, 'lib', 'soap', 'sts' , 'SmsWSClient')

class SmsJob < Struct.new(:message_id)
  def perform
    message = TextMessage.find(message_id)
     
    sms = SmsWSClient.new
    if sms.send_sms(message.to.gsub(/\+/,""), message.message)
      message.sent = true
      message.save! 
      message.bill!
    else
      # TODO unreserve the funds that were reserved when the text message was created!
      raise StandardError.new("Failed to send SMS")
    end
  end    
end