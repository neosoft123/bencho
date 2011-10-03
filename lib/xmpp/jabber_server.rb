class JabberServer
  
  extend JabberDaemon
    
  class << self
  
    def start
      config = load_config
      logfile = get_logfile(config)
      jabber_daemonize(config, logfile, get_pidfile(config)) do
        load_rails
        install_acl
        DRb.start_service(config['drb_server'], JabberManager.new(config['xmpp_domain']))
        puts "DRb listening at #{DRb.uri}"
        DRb.thread.join
      end
    end
  
    def run
      config = load_config
      load_rails
      install_acl
      DRb.start_service(config['drb_server'], JabberManager.new(config['xmpp_domain']))
      puts "DRb listening at #{DRb.uri}"
      DRb.thread.join
    end
  
    def restart
      stop
      start
    end
  
    def stop
      pidfile = get_pidfile(load_config)
      puts 'No such process' and exit unless pidfile.pid
      begin
        puts "Sending TERM signal to process #{pidfile.pid}"
        Process.kill("TERM", pidfile.pid)
      rescue
        puts 'Could not find process'
      ensure
        pidfile.remove
      end
    end
    
    private
    
    def get_pidfile(config)
      PidFile.new(File.join(Dir.pwd, '..', '..', 'log', config['pid_file']))
    end
    
    def get_logfile(config)
      File.join(Dir.pwd, '..', '..', 'log', config['log_file'])
    end
    
    def load_rails
      puts "Loading Rails in #{ENV['RAILS_ENV']} environment"
      require File.join(Dir.pwd, '..', '..', 'config', 'environment')
    end
    
    def load_config
      YAML.load_file(File.join(Dir.pwd, '..', '..', 'config', 'xmpp.yml'))[ENV['RAILS_ENV']]
    end
    
    def install_acl
      acl = ACL.new(%w(deny all
                         allow 192.168.1.*
                         allow localhost))
      DRb.install_acl(acl)
    end
  
  end
  
end