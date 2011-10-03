#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'

environment = ENV["RAILS_ENV"] || "development"

options = { :source => 'backup_production', :dest => 'production', :from => '__from__', :to => '__to__', :debug => false }
OptionParser.new do |opts|
  opts.banner = "Usage: chat_server [options] {start|stop|restart|run}"
    
  opts.on("-s", "--source ARG", "Source database") do |source|
    options[:source] = source
  end
  
  opts.on("-d", "--dest ARG", "Destination database") do |dest|
    options[:dest] = dest
  end
  
  opts.on("-f", "--from ARG", "Login to copy from") do |from|
    options[:from] = from
  end
  
  opts.on("-t", "--to ARG", "Login to copy to") do |to|
    options[:to] = to
  end
    
  opts.on("-e", "--environment ENV", "Run in specific Rails environment") do |e|
    environment = e
  end
  
  opts.on("--debug", "Show debug messages") do
    options[:debug] = true
  end

end.parse!

ENV["RAILS_ENV"] = environment

# Dir.chdir(File.dirname(__FILE__))
# puts "Changing path to #{Dir.pwd}"

puts "Loading Rails in #{ENV['RAILS_ENV']} environment"
require File.join(Dir.pwd, 'config', 'environment')
RAILS_DEFAULT_LOGGER.level = Logger::INFO

puts "Loading source database config: #{options[:source]}"
source_config = YAML.load_file(File.join(Dir.pwd, 'config', 'database.yml'))[options[:source]]
puts "Loading destination database config: #{options[:dest]}"
dest_config = YAML.load_file(File.join(Dir.pwd, 'config', 'database.yml'))[options[:dest]]

puts "Connecting to source database"
ActiveRecord::Base.establish_connection(source_config)

puts "Loading source user: #{options[:from]}"
from = User.find_by_login(options[:from])
raise "User not found: #{options[:from]}" unless from

kis = from.profile.kontact_informations(:include => [:emails, :phone_numbers])
raise "No KIs found" if kis.empty?
puts "#{from.login} has #{kis.length} contacts"

puts "Connecting to destination database"
ActiveRecord::Base.establish_connection(dest_config) unless options[:source] == options[:dest]

puts "Loading destination user: #{options[:to]}"
to = User.find_by_login(options[:to])
raise "User not found: #{options[:to]}" unless to

puts "#{to.login} has #{to.profile.kontacts.count} contacts"

Kontact.transaction do
  kis.each do |ki|
    puts "Copying KI: #{ki.f}"
    new_ki = KontactInformation.new(ki.attributes)
    new_ki.owner = to.profile
    new_ki.should_validate = false
    new_ki.uuid = nil
    ki.save(false)
    puts new_ki.inspect if options[:debug]
    ki.emails.each { |email| 
      e = Email.new(email.attributes)
      e.kontact_information = new_ki
      puts e.inspect if options[:debug]
      e.save(false)
    }
    ki.phone_numbers.each { |num| 
      p = PhoneNumber.new(num.attributes)
      p.kontact_information = new_ki
      puts p.inspect if options[:debug]
      p.save(false)
    }
    
    raise "Something is totally fucked" unless new_ki
    
    k = to.profile.kontacts.create(
      :status => Kontact::CONTACT,
      :parent => to.profile,
      :kontact_information => new_ki
    )
    k.save(false)
  end  
end

to.reload
puts "#{to.login} NOW has #{to.profile.kontacts.count} contacts"




































