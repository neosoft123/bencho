#!/usr/bin/env ruby

ENV["RAILS_ENV"] = "reporting"

require File.join(File.dirname(__FILE__), "..", "config", "environment")

puts "Profile count: #{Profile.count}"

data = {}
Profile.all.each do |p|
  if p.international_dialing_code
    if data.has_key?(p.international_dialing_code.id)
      data[p.international_dialing_code.id] << p.mobile
    else
      data[p.international_dialing_code.id] = [ p.mobile ]
    end
  else
    if data.has_key?(0)
      data[0] << p.mobile
    else
      data[0]  = [p.mobile]
    end
  end
end

data.each do |id, mobiles|
  idl = Rails.cache.fetch('idl') do
    InternationalDialingCode.find(id)
  end unless id == 0
  puts "#{(idl.nil?) ? "Unknown" : idl.country} ==> #{mobiles.length} (#{mobiles[0]})"
end


