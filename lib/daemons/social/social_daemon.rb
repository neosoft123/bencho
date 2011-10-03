class SocialDaemon < DaemonBase

  require 'eventmachine'
  require 'pp'  
  require 'twitter_worker'
  require 'facebook_worker'
  
  attr_accessor :exchange
  
  def initialize config
    @config = config
  end
  
  def do_stuff
    
    log "Starting social daemon"
    
    trap('TERM') { do_exit }
    trap('INT')  { do_exit }
    
    twitter = EM.spawn do
      worker = TwitterWorker.new
      worker.callback { |time| puts "Twitter worker completed at: #{time}" }
      worker.errback { |ex| puts "Twitter worker failed: #{ex}" }
      worker.update_from_twitter
    end
    
    facebook = EM.spawn do
      worker = FacebookWorker.new
      worker.callback { |time| puts "Twitter worker completed at: #{time}" }
      worker.errback { |ex| puts "Twitter worker failed: #{ex}" }
      worker.update_from_facebook
    end
    
    EM.run do
      log "Workers will run every #{@config['work_interval']} secs"
      EM::PeriodicTimer.new(@config['work_interval'].to_i) do
        twitter.notify
        facebook.notify
      end
    end
    
  end
  
  def do_exit
    log "Stopping social daemon.. please wait"
    EM.stop
  end
          
end