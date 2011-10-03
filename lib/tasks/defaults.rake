namespace :kontact do
  
  EMAIL = 'admin@agilisto.com'
  ADMIN_USER = {
    :login => 'admin',
    :email => EMAIL,
    :password => 'lquire', :password_confirmation => 'lquire',
    :terms_of_service=>'1',
    :is_admin => true, 
    :captcha => 'test',
    :captcha_answer => 'test'    
  }
  
  task :defaults => :environment do
    puts "Setting up admin account"
    raise 'User already exists' if Profile.find_by_email EMAIL
    admin = User.new(ADMIN_USER)
    admin.save(false)
  end
  
  desc "Getting started with lovd-by-less"
  task :getting_started => [
    "environment", 
    "lovdbyless:check",
    "gems:dependent:install", 
    "db:create:all", "mig"
    ] do
    puts "Finished setting up environment and application!"
  end
end
