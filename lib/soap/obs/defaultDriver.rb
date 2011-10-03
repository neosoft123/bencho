require File.join( RAILS_ROOT, 'lib', 'soap', 'obs' , 'default')
require File.join( RAILS_ROOT, 'lib', 'soap', 'obs' , 'defaultMappingRegistry')

require 'soap/rpc/driver'

class OnlineBillingSoap < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://www.smartcalltech.co.za/onlinebillingws/onlinebilling.asmx"

  Methods = [
    [ "http://tempuri.org/authenticateUser",
      "authenticateUser",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://tempuri.org/", "authenticateUser"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://tempuri.org/", "authenticateUserResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://tempuri.org/processRequest",
      "processRequest",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://tempuri.org/", "processRequest"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://tempuri.org/", "processRequestResponse"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "http://tempuri.org/processRequest2",
      "processRequest2",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "http://tempuri.org/", "processRequest2"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "http://tempuri.org/", "processRequest2Response"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = DefaultMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = DefaultMappingRegistry::LiteralRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        add_document_operation(*definitions)
      else
        add_rpc_operation(*definitions)
        qname = definitions[0]
        name = definitions[2]
        if qname.name != name and qname.name.capitalize == name.capitalize
          ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
            __send__(name, *arg)
          end
        end
      end
    end
  end
end

