class ChatDaemon < DaemonBase

  require 'eventmachine'
  require 'drb'
  require 'drb/acl'
  require 'chat_manager'
  require 'xmpp4r-simple'
  
  attr_accessor :exchange
  
  def initialize config
    @config = config
  end
  
  def do_stuff
    log "Starting chat daemon"
    
    trap('TERM') { do_exit }
    trap('INT')  { do_exit }
    
    # cache_online_users_for = @config['cache_online_users_for']
    log_callback = proc {|message| log message }
    @manager = ChatManager.create_instance(@config['xmpp_domain'], log_callback)
    
    EM.run do
      log "Usering address: #{green(@config['drb_server'])}"
      DRb.start_service(@config['drb_server'], @manager)
      log "DRb listening at #{green(DRb.uri)}"
      monitor_interval = @config['monitor_interval'].to_i
      log "Daemon will monitor every #{monitor_interval} seconds"
      EM::PeriodicTimer.new(monitor_interval) do
        @manager.monitor
      end
      EM::PeriodicTimer.new(5) do
        @manager.watch
      end
    end
    
  end
  
  def do_exit
    log "Stopping chat daemon.. please wait"
    @manager.do_exit
    EM.stop
  end
            
end