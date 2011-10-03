class TwitterController < ApplicationController
  
  helper :twitter
  
  before_filter :ensure_authenticated_with_twitter
  append_before_filter :got_twitter_login_name
  
  def feed
   
    username = params[:username]
    client = @u.settings.twitter_client
   # @tweets = client.user_timeline(:page => params[:page] || 1)
    @tweets = client.user_timeline(:screen_name => username, :page => params[:page] || 1)
    @tweeter = @tweets.length > 0 ? @tweets[0]["user"] : Twitter.user(username)
    @tweets = WillPaginate::Collection.create(params[:page] || 1, 20, @tweeter["statuses_count"]) do |pager|
      pager.replace @tweets[0, pager.per_page].to_a
    end
    @follows = begin
      client.friendship_exists?(@u.settings.twitter_login, @tweeter["screen_name"])
    rescue Twitter::General
     false
    end
    respond_to do |format|
      format.mobile  
     end
  rescue Twitter::Unauthorized
    flash[:error] = "You unfortunately do not have access to that Twitter feed "
    redirect_to :back
  rescue Twitter::Unavailable
    flash[:error] = "Twitter is currently unavailable, please try again in a moment"
    redirect_to :back
  rescue Twitter::RateLimitExceeded
    flash[:error] = "Twitter query limit exceeded, please try again in a short while"
    redirect_to root_path
  end
  
  def follow
    username = params[:username]
    client = @u.settings.twitter_client
    client.friendship_create(username, true)
    flash[:notice] = "You are now following this user"
    redirect_to twitter_feed_path(username)
  rescue Twitter::Unauthorized
    flash[:error] = "You unfortunately do not have permission to follow that user"
    redirect_to :back
  rescue Twitter::Unavailable
    flash[:error] = "Twitter is currently unavailable, please try again in a moment"
    redirect_to :back
  rescue Twitter::RateLimitExceeded
    flash[:error] = "Twitter query limit exceeded, please try again in a short while"
    redirect_to root_path
  end
  
  def followers
    username = params[:username]
    client = @u.settings.twitter_client
    @tweeter = client.user username
     @followers = client.follower_ids(:screen_name => username, :page => params[:page] || 1)
     @followers = WillPaginate::Collection.create(params[:page] || 1, 100, @tweeter["followers_count"]) do |pager|
     pager.replace @followers[0, pager.per_page].to_a
     end
    respond_to do |format|
      format.mobile
    end
  rescue Twitter::Unauthorized
    flash[:error] = "You unfortunately do not have access to that Twitter feed"
    redirect_to :back
  rescue Twitter::Unavailable
    flash[:error] = "Twitter is currently unavailable, please try again in a moment"
    redirect_to :back
  rescue Twitter::RateLimitExceeded
    flash[:error] = "Twitter query limit exceeded, please try again in a short while"
    redirect_to root_path
  end
  
  def following
    username = params[:username]
    client = @u.settings.twitter_client
    @tweeter = client.user username
    @followers = client.friend_ids(:screen_name => username).paginate(:page => params[:page], :per_page => 50)
   # @followings_123 =  client.friends(:screen_name => username)
   # @followers = WillPaginate::Collection.create(params[:page] || 1, 50, @tweeter["friends_count"]) do |pager|
   #  if(params[:page] == 1 )
   #    pager.replace @followers[0, pager.per_page].to_a
   #  else
   #    pager.replace @followers[50, pager.per_page].to_a
   #  end
   # end
    respond_to do |format|
      format.mobile { render :action => :followers}
    end
  rescue Twitter::Unauthorized
    flash[:error] = "You unfortunately do not have access to that Twitter feed"
    redirect_to :back
  rescue Twitter::Unavailable
    flash[:error] = "Twitter is currently unavailable, please try again in a moment"
    redirect_to :back
  rescue Twitter::RateLimitExceeded
    flash[:error] = "Twitter query limit exceeded, please try again in a short while"
    redirect_to root_path
  end
  
  private
  
    def got_twitter_login_name
      @u.settings.get_twitter_login if @u.settings.twitter_login.blank?
    end
  
    def allow_to
      super :user, :all => true
    end
  

end
