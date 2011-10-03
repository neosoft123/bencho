#!/usr/bin/env ruby

root_path = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
$:.unshift(root_path)

env ||= 'development'

God.pid_file_directory = File.join(root_path, "log")

%w(chat_daemon social_daemon).each do |daemon_name|

  config = YAML.load_file(File.join(root_path, 'config', "#{daemon_name}.yml"))[env]
  pid_file = File.join(root_path, 'log', config['pid_file'])
  
  God.watch do |w|
    w.name = daemon_name
    w.group = "daemons"
    w.interval = 30.seconds
    w.start = "cd #{root_path} && /usr/bin/ruby #{root_path}/script/#{daemon_name} start -e #{env}"
    w.stop = "cd #{root_path} && /usr/bin/ruby #{root_path}/script/#{daemon_name} stop -e #{env}"
    w.restart = "cd #{root_path} && /usr/bin/ruby #{root_path}script/#{daemon_name} restart -e #{env}"
    w.start_grace = 10.seconds
    w.stop_grace = 10.seconds
    w.pid_file = pid_file
    w.behavior(:clean_pid_file)
  
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end
  
    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 10.seconds
        c.running = false
      end
    end
  
  end
end
