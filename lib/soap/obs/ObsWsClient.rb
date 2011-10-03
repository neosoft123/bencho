#!/usr/bin/env ruby
require 'defaultDriver.rb'

endpoint_url = ARGV.shift
obj = OnlineBillingSoap.new(endpoint_url)

# run ruby with -d to see SOAP wiredumps.
obj.wiredump_dev = STDERR if $DEBUG

# SYNOPSIS
#   authenticateUser(parameters)
#
# ARGS
#   parameters      AuthenticateUser - {http://tempuri.org/}authenticateUser
#
# RETURNS
#   parameters      AuthenticateUserResponse - {http://tempuri.org/}authenticateUserResponse
#
parameters = nil
puts obj.authenticateUser(parameters)

# SYNOPSIS
#   processRequest(parameters)
#
# ARGS
#   parameters      ProcessRequest - {http://tempuri.org/}processRequest
#
# RETURNS
#   parameters      ProcessRequestResponse - {http://tempuri.org/}processRequestResponse
#
parameters = nil
puts obj.processRequest(parameters)

# SYNOPSIS
#   processRequest2(parameters)
#
# ARGS
#   parameters      ProcessRequest2 - {http://tempuri.org/}processRequest2
#
# RETURNS
#   parameters      ProcessRequest2Response - {http://tempuri.org/}processRequest2Response
#
parameters = nil
puts obj.processRequest2(parameters)


endpoint_url = ARGV.shift
obj = OnlineBillingSoap.new(endpoint_url)

# run ruby with -d to see SOAP wiredumps.
obj.wiredump_dev = STDERR if $DEBUG

# SYNOPSIS
#   authenticateUser(parameters)
#
# ARGS
#   parameters      AuthenticateUser - {http://tempuri.org/}authenticateUser
#
# RETURNS
#   parameters      AuthenticateUserResponse - {http://tempuri.org/}authenticateUserResponse
#
parameters = nil
puts obj.authenticateUser(parameters)

# SYNOPSIS
#   processRequest(parameters)
#
# ARGS
#   parameters      ProcessRequest - {http://tempuri.org/}processRequest
#
# RETURNS
#   parameters      ProcessRequestResponse - {http://tempuri.org/}processRequestResponse
#
parameters = nil
puts obj.processRequest(parameters)

# SYNOPSIS
#   processRequest2(parameters)
#
# ARGS
#   parameters      ProcessRequest2 - {http://tempuri.org/}processRequest2
#
# RETURNS
#   parameters      ProcessRequest2Response - {http://tempuri.org/}processRequest2Response
#
parameters = nil
puts obj.processRequest2(parameters)


