#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), ".."))

@daemon_name = "chat_daemon"
@config_file = 'chat_daemon.yml'

load "daemon.god"

