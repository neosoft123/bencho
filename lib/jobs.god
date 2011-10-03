#!/usr/bin/env ruby

root_path = File.expand_path(File.join(File.dirname(__FILE__), ".."))
puts root_path
$:.unshift(root_path)
env ||= 'production'

God.watch do |w|
  w.name = "jobs_worker"
  w.group = "daemons"
  w.interval = 30.seconds
  w.start = "cd #{root_path} && RAILS_ENV=#{env} rake jobs:work"
  w.stop = ""
  w.start_grace = 10.seconds
  w.stop_grace = 10.seconds
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


