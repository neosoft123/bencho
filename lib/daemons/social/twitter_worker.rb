class TwitterWorker
  
  include EM::Deferrable
  
  def handle_mysql_error e, &block
    ActiveRecord::Base.connection.reconnect!
    yield if block_given?
  end

  def update_from_twitter
    ActiveRecord::Base.connection.reconnect!
    Settings.with_twitter_credentials.each do |settings|
      settings.get_last_tweet
      settings.get_friends_tweets
     
   end
    succeed(Time.now)
  rescue ActiveRecord::StatementInvalid => e
    handle_mysql_error(e) { update_from_twitter }
  rescue => e
    HoptoadNotifier.notify(e)
    fail(e)
  end

end
