require File.join( RAILS_ROOT, 'lib', 'soap', 'obs' , 'defaultDriver')

class BillingError < StandardError
  attr_accessor :response
  def initialize(response)
    @response = response
  end
end

# Simple billling facade. Not thread safe, called serially from billing worker at the moment.
class ObsClient

  class InvalidTokenError < BillingError 
  end
  
  class InvalidServiceError < BillingError
  end
  
  class InsufficientFundsError < BillingError
  end
  
  class OtherError < BillingError
  end
  
  class BillingResponse
    attr_accessor :code, :reason, :reference
    def initialize(code, reference, reason)
      @code, @reason, @reference = code, reason, reference
    end
  end
  
  login_file = File.read(RAILS_ROOT + "/config/sts_account.yml")
  
  @@account = YAML.load(login_file)['account']
  @@obs = OnlineBillingSoap.new
  @@obs.wiredump_dev = STDERR
  @@token = nil
  @@token_issued = nil
  @@token_retries = 0
  TOKEN_RETRIES = 3
  
  # token = nil, serviceguid = nil, msisdn = nil, contentdescription = nil, transactionid = nil, subtype = nil, subdate = nil)
  def self.process_request(options = {})
    authenticate
    puts "Authenticated #{@@token}"
    
    request = ProcessRequest2.new(@@token, options[:service], options[:msisdn], 
      options[:description], options[:tx_id], options[:sub_type], options[:sub_date])
    begin
      response = @@obs.processRequest2(request)
    rescue => e
      puts e.inspect
      puts e.backtrace
      raise e
    end
    
    result = BillingResponse.new(response.errorcode, response.responseref, response.responsedescription)
    debugger
    case response.errorcode
      when "00"
        return result
      when "02"
        raise InvalidTokenError.new
      when "03"
        raise InvalidServiceError.new
      when "04"
      when "05"
        raise StandardError.new(result)
      when "51"
        raise InsufficientFundsError.new(result)
      when "99"
        raise OtherError.new(result)
    end
    @@token_retries = 0
    # Retry the token process if the token has expired
    rescue InvalidTokenError => e
      @@token = nil
      @@token_retries += 1
      retry if @@token_retries < TOKEN_RETRIES
      raise e
  end
  
  private
  def self.authenticate
    puts "Token Age : #{DateTime.now - @@token_issued}" if @@token_issued
    return @@token if @@token and @@token_issued and (DateTime.now - @@token_issued < 30.seconds) 
    puts "Requesting new token"
    request = AuthenticateUser.new(@@account["username"], @@account["password"])
    response = @@obs.authenticateUser(request)
    @@token = response.authenticateUserResult ? response.token : false
  end

end