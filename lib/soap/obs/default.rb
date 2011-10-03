require 'xsd/qname'

# {http://tempuri.org/}authenticateUser
#   username - SOAP::SOAPString
#   password - SOAP::SOAPString
class AuthenticateUser
  attr_accessor :username
  attr_accessor :password

  def initialize(username = nil, password = nil)
    @username = username
    @password = password
  end
end

# {http://tempuri.org/}authenticateUserResponse
#   authenticateUserResult - SOAP::SOAPString
#   token - SOAP::SOAPString
class AuthenticateUserResponse
  attr_accessor :authenticateUserResult
  attr_accessor :token

  def initialize(authenticateUserResult = nil, token = nil)
    @authenticateUserResult = authenticateUserResult
    @token = token
  end
end

# {http://tempuri.org/}processRequest
#   token - SOAP::SOAPString
#   serviceguid - SOAP::SOAPString
#   msisdn - SOAP::SOAPString
#   contentdescription - SOAP::SOAPString
#   transactionid - SOAP::SOAPInt
class ProcessRequest
  attr_accessor :token
  attr_accessor :serviceguid
  attr_accessor :msisdn
  attr_accessor :contentdescription
  attr_accessor :transactionid

  def initialize(token = nil, serviceguid = nil, msisdn = nil, contentdescription = nil, transactionid = nil)
    @token = token
    @serviceguid = serviceguid
    @msisdn = msisdn
    @contentdescription = contentdescription
    @transactionid = transactionid
  end
end

# {http://tempuri.org/}processRequestResponse
#   processRequestResult - SOAP::SOAPString
#   responseref - SOAP::SOAPString
#   responsedescription - SOAP::SOAPString
#   errorcode - SOAP::SOAPString
class ProcessRequestResponse
  attr_accessor :processRequestResult
  attr_accessor :responseref
  attr_accessor :responsedescription
  attr_accessor :errorcode

  def initialize(processRequestResult = nil, responseref = nil, responsedescription = nil, errorcode = nil)
    @processRequestResult = processRequestResult
    @responseref = responseref
    @responsedescription = responsedescription
    @errorcode = errorcode
  end
end

# {http://tempuri.org/}processRequest2
#   token - SOAP::SOAPString
#   serviceguid - SOAP::SOAPString
#   msisdn - SOAP::SOAPString
#   contentdescription - SOAP::SOAPString
#   transactionid - SOAP::SOAPInt
#   subtype - SOAP::SOAPString
#   subdate - SOAP::SOAPDateTime
class ProcessRequest2
  attr_accessor :token
  attr_accessor :serviceguid
  attr_accessor :msisdn
  attr_accessor :contentdescription
  attr_accessor :transactionid
  attr_accessor :subtype
  attr_accessor :subdate

  def initialize(token = nil, serviceguid = nil, msisdn = nil, contentdescription = nil, transactionid = nil, subtype = nil, subdate = nil)
    @token = token
    @serviceguid = serviceguid
    @msisdn = msisdn
    @contentdescription = contentdescription
    @transactionid = transactionid
    @subtype = subtype
    @subdate = subdate
  end
end

# {http://tempuri.org/}processRequest2Response
#   processRequest2Result - SOAP::SOAPString
#   responseref - SOAP::SOAPString
#   responsedescription - SOAP::SOAPString
#   errorcode - SOAP::SOAPString
class ProcessRequest2Response
  attr_accessor :processRequest2Result
  attr_accessor :responseref
  attr_accessor :responsedescription
  attr_accessor :errorcode

  def initialize(processRequest2Result = nil, responseref = nil, responsedescription = nil, errorcode = nil)
    @processRequest2Result = processRequest2Result
    @responseref = responseref
    @responsedescription = responsedescription
    @errorcode = errorcode
  end
end
