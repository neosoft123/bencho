require File.join( RAILS_ROOT, 'lib', 'soap', 'obs' , 'default')
require 'soap/mapping'

module DefaultMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsTempuriOrg = "http://tempuri.org/"

  LiteralRegistry.register(
    :class => AuthenticateUser,
    :schema_name => XSD::QName.new(NsTempuriOrg, "authenticateUser"),
    :schema_element => [
      ["username", "SOAP::SOAPString", [0, 1]],
      ["password", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => AuthenticateUserResponse,
    :schema_name => XSD::QName.new(NsTempuriOrg, "authenticateUserResponse"),
    :schema_element => [
      ["authenticateUserResult", "SOAP::SOAPString", [0, 1]],
      ["token", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ProcessRequest,
    :schema_name => XSD::QName.new(NsTempuriOrg, "processRequest"),
    :schema_element => [
      ["token", "SOAP::SOAPString", [0, 1]],
      ["serviceguid", "SOAP::SOAPString", [0, 1]],
      ["msisdn", "SOAP::SOAPString", [0, 1]],
      ["contentdescription", "SOAP::SOAPString", [0, 1]],
      ["transactionid", "SOAP::SOAPInt"]
    ]
  )

  LiteralRegistry.register(
    :class => ProcessRequestResponse,
    :schema_name => XSD::QName.new(NsTempuriOrg, "processRequestResponse"),
    :schema_element => [
      ["processRequestResult", "SOAP::SOAPString", [0, 1]],
      ["responseref", "SOAP::SOAPString", [0, 1]],
      ["responsedescription", "SOAP::SOAPString", [0, 1]],
      ["errorcode", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => ProcessRequest2,
    :schema_name => XSD::QName.new(NsTempuriOrg, "processRequest2"),
    :schema_element => [
      ["token", "SOAP::SOAPString", [0, 1]],
      ["serviceguid", "SOAP::SOAPString", [0, 1]],
      ["msisdn", "SOAP::SOAPString", [0, 1]],
      ["contentdescription", "SOAP::SOAPString", [0, 1]],
      ["transactionid", "SOAP::SOAPInt"],
      ["subtype", "SOAP::SOAPString", [0, 1]],
      ["subdate", "SOAP::SOAPDateTime"]
    ]
  )

  LiteralRegistry.register(
    :class => ProcessRequest2Response,
    :schema_name => XSD::QName.new(NsTempuriOrg, "processRequest2Response"),
    :schema_element => [
      ["processRequest2Result", "SOAP::SOAPString", [0, 1]],
      ["responseref", "SOAP::SOAPString", [0, 1]],
      ["responsedescription", "SOAP::SOAPString", [0, 1]],
      ["errorcode", "SOAP::SOAPString", [0, 1]]
    ]
  )
end
