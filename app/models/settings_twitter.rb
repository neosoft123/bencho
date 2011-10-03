class Settings
  
  # named_scope :with_twitter_credentials, :conditions => "twitter_login is not null and twitter_password is not null"
  named_scope :with_twitter_credentials, :conditions => "twitter_oauth_token is not null and twitter_oauth_secret is not null"
  
  def has_twitter_login?
    authorized_with_twitter?
    # !self.twitter_login.blank? && !self.twitter_password.blank?
  end
  
  # def validate_twitter_login(uid, pwd)
  #   twitter = Twitter::Client.new(:login => uid, :password => pwd)
  #   twitter.my :followers
  #   true
  # rescue Twitter::RESTError => e
  #   false
  # end
  
  def authorize_with_twitter! token, secret
    self.update_attributes(
      :twitter_oauth_token => oauth.access_token.token, 
      :twitter_oauth_secret => oauth.access_token.secret
    )
  end
  
  def deauthorize_with_twitter!
#    self.update_attributes(
#      :twitter_oauth_token => nil, 
#      :twitter_oauth_secret => nil
#    )
  end
  
  def authorized_with_twitter?
    !self.twitter_oauth_secret.blank? && !twitter_oauth_token.blank?
  end
  
  def oauth
    #@oauth ||= Twitter::OAuth.new(TWITTER_CONFIG['consumer_key'], TWITTER_CONFIG['consumer_secret'])
    @oauth ||= Twitter::OAuth.new("MyYBKICB6Oe9XyQmYMui2g", "A7w8JjWu0SDnhMEHbGANri0CxQCfIjt6Dokjk3ouA")
  end
  
  def tweet text, options={}
    tweet = twitter_client.update(text, options)
  end
  
  def twitter_client
    @client ||= begin
      oauth.authorize_from_access(twitter_oauth_token, twitter_oauth_secret)
      Twitter::Base.new(oauth)
    end
  end
  
  def get_twitter_login
    tweet = twitter_client.user_timeline(:count => 1).first
    self.update_attribute :twitter_login, tweet['user']['screen_name']
    true
  rescue => e
    raise e if RAILS_ENV == 'development'
    false
  end

  def getfollowers
     @client = self.twitter_client
     @client_followers_all= @client.followers()
  end

  def getfollowing
    @client = self.twitter_client
      @client_followings_all = @client.friends()    
  end
  
  def get_last_tweet
    puts "Checking last tweet for user: #{self.user.login}"
    return unless authorized_with_twitter?
    tweet = twitter_client.user_timeline(:count => 1).first rescue nil
    status = self.user.profile.profile_statuses.first.text.strip rescue ""
    if tweet
      unless tweet["id"] == self.last_tweet_id
       #   @getst = self.user.profile.profile_statuses.find(:first, :conditions => 'twitter_status_id => #{tweet["id"]}')                      
       #if @getst
       #  puts "Twitter feed already saved"
       #else
      unless ProfileStatus.exists?(:twitter_status_id => tweet["id"].to_i)
        if self.user.profile.profile_statuses.empty? || status != tweet["text"].strip
          transaction do
            puts "Setting profile status: #{tweet.text}"
            self.user.profile.profile_statuses.create!(:text => tweet["text"], :twitter_status_id => tweet["id"])
            puts "Setting last tweet ID: #{tweet.id}"
            self.update_attribute(:last_tweet_id, tweet["id"])
          end
        end
       end
      end
    end
  rescue Crack::ParseError
    puts "Invalid Twitter response - nothing we can do about this, ignoring"
  rescue Twitter::Unavailable
    puts "Twitter API error - nothing we can do about this, ignoring"
  rescue Twitter::RateLimitExceeded
    puts "API limit exceeded for: #{self.user.login}"
  rescue EOFError
    puts "Twitter API error - nothing we can do about this, ignoring"
  rescue Errno::ETIMEDOUT
    puts "Timeout connecting to Twitter API - nothing we can do about this, ignoring"
  rescue Twitter::Unauthorized
 #   deauthorize_with_twitter!
  rescue ActiveRecord::StatementInvalid => e
    raise e # raise this to be handled externally
  rescue Timeout::Error
    nil
  rescue => e
    puts e.inspect
    HoptoadNotifier.notify(e)
  end
  
  def get_friends_tweets
    puts "Getting friend tweets for user: #{self.user.login}"
    return unless authorized_with_twitter?
    tweets = twitter_client.friends_timeline
    if tweets && !tweets.empty?
      puts "Found #{tweets.length} new tweets"
      tweets = tweets.reverse
      tweets.each do |tweet|
        unless TwitterStatus.exists?(:status_id => tweet["id"].to_i)
          t = TwitterStatus.new(:profile => self.user.profile)
          t.text = tweet["text"]
          t.status_id = tweet["id"].to_i
          t.name = tweet["user"]["name"]
          t.screen_name = tweet["user"]["screen_name"]
          t.avatar_url = tweet["user"]["profile_image_url"]
          t.posted_at = tweet["created_at"]
          t.save
          puts "Tweet from #{t.name}: #{t.text}"
        end
      end
    end
    self.update_attribute(:last_twitter_check, Time.now)
    puts "Set last twitter check: #{last_twitter_check}"
  rescue Crack::ParseError
    puts "Invalid Twitter response - nothing we can do about this, ignoring"
  rescue Twitter::Unavailable
    puts "Twitter API error - nothing we can do about this, ignoring"
  rescue Twitter::RateLimitExceeded
    puts "API limit exceeded for: #{self.user.login}"
  rescue EOFError
    puts "Twitter API error - nothing we can do about this, ignoring"
  rescue Errno::ETIMEDOUT
    puts "Timeout connecting to Twitter API - nothing we can do about this, ignoring"
  rescue Twitter::Unauthorized
  #  deauthorize_with_twitter!
  rescue ActiveRecord::StatementInvalid => e
    raise e # raise this to be handled externally
  rescue Timeout::Error
    nil
  rescue => e
    puts e.inspect
    HoptoadNotifier.notify(e)
  end
  
end
