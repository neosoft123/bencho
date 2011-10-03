require File.join(RAILS_ROOT, 'lib', 'soap', 'sts' , 'SmsWSClient')

module MobilisedController

  ## MESSAGE VIEWS
  def welcome_sms(profile)
    url = confirm_url(:id => profile.user, :code => profile.user.make_mobile_activation_code)
    code = profile.user.mobile_activation_code
    render_to_string :partial => "sms/welcome" , :locals => { :url => url , :profile => profile , :code => code }
  end
  
  def resend_confirmation_sms(profile)
    url = confirm_url(:id => profile.user, :code => profile.user.make_mobile_activation_code)
    code = profile.user.mobile_activation_code
    render_to_string :partial => "sms/resend_confirm" , :locals => { :url => url , :profile => profile , :code => code }
  end
  
  def changed_sms(profile)
    #TODO: Is this correct?
    url = "http://" 
    url << request.host
    url << confirm_path(:id => profile , :code => profile.user.make_mobile_activation_code )
    
    render_to_string :partial => "sms/changed_mobile" , :locals => { :url => url , :profile => profile } 
  end
  
  ## ACTIONS
  
  def send_welcome_sms(profile)
    SmsWorker.async_send_sms({ :profile => profile, :message => welcome_sms(profile) })
  end
  
  def send_sms(number , message)
    number = sanitize_number(number)
    RAILS_DEFAULT_LOGGER.error "Starting sms send.."
    RAILS_DEFAULT_LOGGER.error "Number for sms: #{number}"
    sms = SmsWSClient.new
    if sms.send_sms(number , message)
      RAILS_DEFAULT_LOGGER.error "Mobilised: Welcome sms sent to " + number
    else
      RAILS_DEFAULT_LOGGER.error "Mobilised: failed sending sms"
      return false
    end
    true
  rescue => e
    RAILS_DEFAULT_LOGGER.error "Mobilised: " + e.to_s
    RAILS_DEFAULT_LOGGER.error e.inspect
    RAILS_DEFAULT_LOGGER.error e.backtrace
    false
  end
  
  def sanitize_number(number)
    number = number.gsub(/\+27/,'0')
  end
  
end
