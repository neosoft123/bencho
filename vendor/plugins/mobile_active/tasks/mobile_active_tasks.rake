require 'open-uri'
require 'pp'

WURFL_URI = "http://sourceforge.net/projects/wurfl/files/WURFL/latest/wurfl-latest.zip/download"
WURFL_ZIP = File.join(File.dirname(__FILE__), "/../wurfl/wurfl-latest.zip")
WURFL = File.join(File.dirname(__FILE__), '/../wurfl/wurfl.xml')

namespace :mobile_active do
  
  desc "Remove old data, update and import WURFL data"
  task :clean_update => [
    :update_wurfl,
    :clear_devices,
    :import_devices
  ]
  
  desc "Update and import WURFL data"
  task :update => [
    :update_wurfl,
    :import_devices
  ]
  
  desc "Download the latest WURLF data" 
  task :update_wurfl do
    begin
      require 'fileutils'
      puts "Downloading latest WURFL File to #{WURFL}"
      backup = WURFL + ".#{Time.now.to_i}"
      if File.exists?(WURFL)
        puts "Backing up WURFL file to #{backup}"
        FileUtils.mv(WURFL, backup, :verbose => true)
      end
      FileUtils.cd(File.join(File.dirname(__FILE__), "../wurfl"), :verbose => true)
      system "rm #{WURFL_ZIP}" if File.exists?(WURFL_ZIP)
      system "wget -c #{WURFL_URI}"
      system "tar xvf #{WURFL_ZIP}"
    rescue => err
      puts "ERROR: #{err}"
      FileUtils.mv(backup, WURFL, :verbose => true) if File.exists?(backup)
    end
  end
  
  desc "Clear all WURFL device data"
  task :clear_devices => :environment do
    
    puts "Destroying all WURFL devices.."
    WurflDevice.delete_all
    WurflCapability.delete_all
    puts "Done"
    
  end
  
  desc "Import WURFL device data"
  task :import_devices => :environment do
            
    class BasicListener
      
      def initialize
        cr = "\r"           
        clear = "\e[0K"
        @reset = cr + clear
        @chars = %w{ | / - \\ }
        @t = Thread.fork do
          loop { write_log }
        end
      end
      
      def colorize color, text
        "\033[#{color}m#{text}\033[0m"
      end
      
      def red text
        colorize 31, text
      end

      def cyan text
        colorize 36, text
      end

      def green text
        colorize 32, text
      end

      def log message
        @message = message
      end
        
      def write_log
        print "#{@reset}#{green(@chars[0])} #{@message}"
        sleep 0.1
        @chars.push(@chars.shift)
        $stdout.flush
      end

      def tag_start name, attribs
        case name
        when "device"
          log "Looking up device: #{cyan(attribs['id'])}" # (#{attribs['user_agent']})"
          @device = WurflDevice.find_by_xml_id(attribs['id'])
          log "Device found" if @device
          unless @device
            log "Not found, creating device.."
            @device = WurflDevice.new(
              :xml_id => attribs['id'],
              :user_agent => attribs['user_agent'],
              :fall_back => attribs['fall_back']
            )
          end
          @caps = @device.wurfl_capabilities
          log "Loaded #{@caps.length} capabilities"
        when "capability"
          if @device
            log "Looking for #{red(attribs['name'])} on device: #{cyan(@device.xml_id)}"
            unless attribs['value'].blank?
              cap = @device.wurfl_capabilities.find_by_name(attribs['name']) unless @device.new_record?
              if cap
                unless cap.value == attribs['value']
                  log "Updating capability: #{red(cap.name)} = #{cyan(attribs['value'])}"
                  cap.update_attribute(:value, attribs['value'])
                else
                  log "Unchanged capability: #{red(cap.name)}"
                end
              else
                log "Adding capability: #{red(attribs['name'])} = #{cyan(attribs['value'])}"
                @device.wurfl_capabilities.push(WurflCapability.new(
                  :name => attribs['name'],
                  :value => attribs['value'])
                )
              end
            else
              log "Empty capability: #{red(attribs['name'])}"
            end
          end
        end
      end

      def tag_end name
        case name
        when "device"
          log "Gathered data for: #{cyan(@device.xml_id)} (#{@device.wurfl_capabilities.length} capabilities)"
          @device.save!
          @device = nil
        when "wurfl"
          log "Document parsing complete"
          @t.kill
        end
      end

      def method_missing *args
        # do nothing, we don't care about other tags
      end

    end
    
    puts "Importing WURLF Device Data.."
        
    require File.join(File.dirname(__FILE__), '..', 'app','models', 'wurfl_device')
    require File.join(File.dirname(__FILE__), '..', 'app','models', 'wurfl_capability')
    
    raise "File not found" unless File.exists?(WURFL)
    puts "Opening WURFL file.."
    file = File.open(WURFL, 'r').read
    puts "File opened, parsing XML.."
    # WurflDevice.transaction { REXML::Document.parse_stream(file, BasicListener.new) }
    # no need for a transaction really..
    REXML::Document.parse_stream(file, BasicListener.new)
    puts "Done"
    
  end
end