module JabberDaemon
  
  def jabber_daemonize(config, logfile, pidfile, &block)
    
    pidfile.ensure_empty! "ERROR: It looks like I'm already running.  Not starting."
    
    puts "DAEMON POWER! Leaving process #{$$}"
    
    srand # Split rand streams between spawning and daemonized process
    #fork and exit # Fork and exit from the parent
    fork do
    
    puts "Daemonizing on process #{$$}" 
    #puts system("ps aux | grep #{$$}")
    
    # trap('TERM') { do_exit }
    # trap('INT') { do_exit }
        
    #Dir.chdir "/"   # Release old working directory
    File.umask 0000 # Ensure sensible umask
    
    puts 'Making sure all file descriptors are closed'
    ObjectSpace.each_object(IO) do |io|
      unless [STDIN, STDOUT, STDERR].include?(io)
        begin
          io.close unless io.closed?
        rescue ::Exception
        end
      end
    end
    
    puts "Logging to: #{logfile}"
    
    puts "Writing PID file: #{pidfile.file}"
    pidfile.create
    
    puts 'Detaching from the controlling terminal'
    unless sess_id = Process.setsid
      raise 'cannot detach from controlling terminal'
    end
    
    # Redirect IO
    STDIN.reopen('/dev/null')
    STDOUT.reopen(logfile, 'a')
    STDERR.reopen(STDOUT)
    
    block.call
    
    end
    
  end
  
end