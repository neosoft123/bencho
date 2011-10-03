# Install hook code here
# Move migrations over
require "ftools"

puts "Copying migrations"
RAILS_ROOT = File.dirname(__FILE__) + "/../../../" unless defined? RAILS_ROOT
ORIGIN = File.join(File.dirname(__FILE__), 'db','migrate')
DEST = File.join(RAILS_ROOT, 'db', 'migrate')
migrations = Dir.entries(ORIGIN)

migrations.each do |migration|
  next if migration =~ /^\./
  puts "Copying #{migration}"   
  File.copy(File.join(ORIGIN, migration), File.join(DEST, migration)) 
end

puts "Please run the migrations"

