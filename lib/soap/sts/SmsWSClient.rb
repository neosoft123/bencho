# Author Casper Peter Lotter
require File.join( RAILS_ROOT, 'lib', 'soap', 'sts' , 'defaultDriver')

class SmsWSClient
  
  class << self
    def no_authorisation_error  
      raise "SmsWSErrors: Unable to Login"
    end
  
    def invalid_token_error
      raise "SmsWSErrors: Invalid Token"
    end
    
    def invalid_source_address_error
      raise "SmsWSErrors: Invalid Source Address"    
    end
    
    def invalid_number_error
      raise "SmsWSErrors: InvalidNumber"
    end
    
    def not_implemented_error
      raise "SmsWSErrors: Not Implemented"
    end
  end
  
  RESPONSE_HANDLER =    { 'Success' => true , 'InvalidSourceAddress' => Proc.new { SmsWSClient.invalid_source_address_error } ,
                        'InvalidToken' => Proc.new { SmsWSClient.invalid_token_error } , 'Failed' => false ,
                        'InvalidNumber' => Proc.new { SmsWSClient.invalid_number_error }  } 

  def initialize
    login_file = File.read(RAILS_ROOT + "/config/sts_account.yml")
    account = YAML.load(login_file)['account']
    
    @retry = true
    @password = account['password']
    @username = account['username']
    @campaign_id = account['serviced']
    @reference = account['reference']
    @endpoint = account['endpoint']
    RAILS_DEFAULT_LOGGER.error("ENDPOINT #{@endpoint}")
    @obj = SmsWSSoap.new(@endpoint)
    @obj.wiredump_dev = STDERR if $DEBUG
  end

  def send_sms(cell , msg)
    @cell = cell
    @msg = msg
    @token ||= self.login
    if @token
      s = SendSMS.new(@token , cell , msg , @reference , @campaign_id)
      response = @obj.sendSMS(s)
      return process_response(RESPONSE_HANDLER[response.sendSMSResult])  
    else
      update_token
    end
  end
  
  def send_binary_sms(cell, header, part)
    @cell = cell
    @token ||= self.login
    if @token
      s = SendBinaryString.new(@token, cell, header + part, @reference, @campaign_id)
      response = @obj.sendBinaryString(s)
      result = process_response(RESPONSE_HANDLER[response.sendBinaryStringResult])
      return result
    else
      update_token
    end
  end
  
  def send_wap_link(cell, href, msg)
    @cell = cell
    @msg = msg
    @token ||= self.login
    if @token
      s = SendWAPLink.new(@token , cell , href, msg , @reference , @campaign_id)
      response = @obj.sendWAPLink(s)
      return process_response(RESPONSE_HANDLER[response.sendWAPLinkResult])  
    else
      update_token
    end
  end
  
  protected
  
  def process_response(response_handler)
    response_handler.class == Proc ? response_handler.call : response_handler
  end
  
  def update_token
    @retry ? @token = self.login : ( raise no_authorisation_error )
    @retry = false
  end
  
  def retry_sms
    send_sms(@cell , @msg) if @retry
    @retry = false
  end
  
  def login
    l = Login.new(@username , @password)      
    response = @obj.login(l)
    response.loginResult ? @token = response.token : false
  end
end


