require 'digest/sha1'
include ActionController::UrlWriter

class Invitation < ActiveRecord::Base
  
  belongs_to :profile
  belongs_to :kontact
  
  before_create :generate_code
      
  def generate_code
    self.code = UUIDTools::UUID.random_create.to_s[0,8]
    # self.code = Digest::SHA1.hexdigest("-#{profile.id}-#{kontact.id}-")
    self.code
  end
  
  def invitation_message
    url = invitation_url(self.code)
    href = Shortlink.shortlinkify(url)
    sender = self.profile
    builder = SmsBuilder.new(:partial => "sms/invitation")
    message = builder.render_to_string(binding)
    message
  end
  
  def send_invite
   # url = invitation_url(self.code)
    
    # Locals for partial rendering
    href = Shortlink.shortlinkify(self.code)
    sender = self.profile
    kontact = self.kontact
    
    num = self.kontact.kontact_information.phone_numbers.mobile.first
    
    unless num
      raise NoPhoneNumber.new()
    end
    
    msisdn = Msisdn.new(num.value)
    
    RAILS_DEFAULT_LOGGER.debug "Sending to #{msisdn.to_national}"
    
    service = Service.find_by_title(Service::FRIEND_INVITE_SERVICE)
    raise StandardError.new('Friend Invite Service not found. Please run rake task') unless service
    
    builder = SmsBuilder.new(:partial => "sms/invitation")
    message = builder.render_to_string(binding)
    
    text_message = sender.text_messages.create(
        :recipient => sender,
        :to => msisdn.to_national, :message => message,
        :billable => true,
        :billed_to => sender,
        :service => service)
        
    Delayed::Job.enqueue(SmsJob.new(text_message.id))
  end
    
end
