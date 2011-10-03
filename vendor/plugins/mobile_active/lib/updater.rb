class WurflUpdater
  
  require 'fileutils'

  WURFL_REPO = "http://wurfl.sourceforge.net/wurfl.xml"
  WURFL = File.join(File.dirname(__FILE__), '../wurfl/wurfl.xml')

  class << self
    
    def update
      
      begin
        puts "Downloading latest WURFL File to #{WURFL}"
        backup = WURFL + ".#{Time.now.to_i}"
        if File.exists?(WURFL)
          puts "Backing up WURFL file to #{backup}"
          FileUtils.mv(WURFL, backup, :verbose => true)
        end
        FileUtils.cd(File.join(File.dirname(__FILE__), "../wurfl"), :verbose => true)
        exec "wget #{WURFL_REPO}"
      rescue => err
        puts "ERROR: #{err}"
        FileUtils.mv(backup, WURFL_REPO, :verbose => true) if File.exists?(backup)
      end
      
    end
    
  end
  
end

