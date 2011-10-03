#!/usr/bin/env ruby

RAILS_ROOT = File.join(File.dirname(__FILE__), "..", "..")

ENV['RAILS_ENV'] ||= 'production'

God.watch do |w|
  
  w.name = "chat_server"
  w.interval = 30.seconds
  w.start = "ruby #{RAILS_ROOT}/script/chat_server start -e #{ENV['RAILS_ENV']}"
  w.stop = "ruby #{RAILS_ROOT}/script/chat_server stop -e #{ENV['RAILS_ENV']}"
  w.restart = "ruby #{RAILS_ROOT}/script/chat_server restart -e #{ENV['RAILS_ENV']}"
  w.start_grace = 2.minutes
  w.stop_grace = 20.seconds
  config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'xmpp.yml'))[ENV['RAILS_ENV']]
  w.pid_file = File.join(RAILS_ROOT, 'log', config['pid_file'])
  w.behavior(:clean_pid_file)
  
  w.start_if do |start|
    start.condition(:process_running) do |c|
      # c.interval = 5.seconds
      c.running = false
    end
  end
  
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
  
end


