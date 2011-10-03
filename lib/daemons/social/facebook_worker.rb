class FacebookWorker

  include EM::Deferrable
  
  def handle_mysql_error e, &block
    ActiveRecord::Base.connection.reconnect!
    yield if block_given?
  end

  def update_from_facebook
    ActiveRecord::Base.connection.reconnect!
    Settings.with_facebook_credentials.each do |settings|
   
      settings.get_last_facebook_status
      settings.get_friends_statuses
   
    end
    succeed(Time.now)
  rescue ActiveRecord::StatementInvalid => e
    handle_mysql_error(e) { update_from_facebook }
  rescue => e
    HoptoadNotifier.notify(e)
    fail(e)    
  end

end
