require 'digest/md5'

class DuplicateRemover
  attr_accessor :profile, :kontacts, :to_delete
  def initialize(login)
    puts "Started"
    @profile = User.find_by_login(login).profile
  end
  
  def clean
    @to_delete, @kontacts = [], {}
    
    @profile.kontact_informations.each do |k|
      digest = digest(k)
      puts "Processing #{k.display_name} (#{digest})"
      @to_delete << k if @kontacts.keys.include?(digest)
      @kontacts[digest] = k
      puts "Duplicates #{@to_delete.length} Kontacts #{@kontacts.length}"
    end
    
  end
  
  private
  def digest(ki)
    #ki = k.kontact_information
    key = "#{ki.display_name}#{ki.family_name}#{ki.given_name}"
    key << ki.phone_numbers.collect {|p| p.field_type + p.value unless p.field_type.nil?}.to_s
    key << ki.emails.collect {|e| e.field_type + e.value unless e.field_type.nil?}.to_s
    digest = Digest::MD5.hexdigest(key)
    puts "Converted #{key}"
    puts "Digest #{digest}"
    digest
  end
end

cleaner = DuplicateRemover.new('armanddp')
puts "Cleaning for #{cleaner.profile.display_name}"
cleaner.clean

puts "Done"
puts "Results"
puts "-------"

cleaner.kontacts.each do |k,v|
  puts "Keeping #{v.display_name}"
end

puts "\n\n-----\n\n"

cleaner.to_delete.each do |v|
  puts "Deleting #{v.display_name}"
  kontact =  v.kontacts.first
  kontact.destroy
  v.destroy
end
