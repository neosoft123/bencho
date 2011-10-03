#!/usr/bin/env ruby

require 'rubygems'

environment = ENV["RAILS_ENV"] || "development"

ENV["RAILS_ENV"] = environment

Dir.chdir(File.dirname(__FILE__))

puts "Loading Rails in #{ENV['RAILS_ENV']} environment"
require File.join(Dir.pwd, '..', '..', 'config', 'environment')

users = User.all(:limit => 5)

users.each do |u|
  # next if u.login == "ldapadmin"
  # u.password = "pass"
  # u.save!
  puts "#{u.login} signing in"
  u.signon("pass")
  sleep 1
end

users.each do |u|
  users.each do |to|
    1.times do
      begin
        puts "#{u.login} sending message to #{to.login}"
        u.send_message(to, UUID.random_create.to_s[0,50])
        sleep 1
      rescue => e
        puts e.message
      end
    end
  end
  break
end

# puts "Sleeping...."
# sleep 10
# users.each { |u| puts "#{u.login} signing out"; u.signout; sleep 1; }
