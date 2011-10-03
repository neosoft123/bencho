#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), ".."))

@daemon_name = "social_daemon"
@config_file = 'social_daemon.yml'

load "daemon.god"

