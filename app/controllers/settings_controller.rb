class SettingsController < ApplicationController
  
  append_before_filter :ensure_authenticated_with_twitter, :only => [:twitter_options, :twitter_do]
  before_filter :ensure_authenticated_to_facebook, 
   :only => [ :facebook_options, :facebookauth, :facebook_do, :facebook_key, 
   :facebook_extended_auth, :facebook_extended_read_auth ]
  

  # before_filter :ensure_has_publish_stream, :only => [ :facebook_extended_auth ]
  # before_filter :ensure_has_read_stream, :only => [ :facebook_extended_read_auth ]
 # append_before_filter :get_fbuser, :only => [ :facebook_options, :facebook_do ]
  skip_filter :store_location, :only => [
    :fireeagle_callback, :fireeagle_off, :facebook_do, :facebookauth, 
    :facebook_extended_auth, :twitter_do, :twitter_off,
    :twitter_requestauth, :twitterauth
  ]
  
  def index
  end
  
  def show
    render :action => :index
  end
  
  def privacy
    
  end
  
  def privacy_do
    Settings.transaction do
      @u.settings.update_attribute(:show_in_public_searches, params[:search_show] ? true : false)
      @u.settings.update_attribute(:show_in_public_timeline, params[:timeline_show] ? true : false)
    end
    flash[:notice] = "<h3>Privacy settings updated</h3>You will now " + 
      (@u.settings.show_in_public_searches? ? "" : "NOT ") + "show up in public profile searches and " +
      "your updates " + (@u.settings.show_in_public_timeline? ? "will" : "will not") + " appear in the " +
      "global activity stream."
    redirect_to settings_path
  end
  
  def fireeagle
  end
  
  def fireeagle_off
    @u.settings.update_attributes(:fireeagle_access_token => nil, :fireeagle_access_token_secret => nil)
    flash[:notice] = "Location updates will no longer be sent to Fire Eagle"
    redirect_to settings_path
  end
    
  def fireeagle_callback
    user = Settings.find_by_fireeagle_request_token(params[:oauth_token]).user rescue nil
    if user
      respond_to do |format|
        if user.settings.authorize_with_fireeagle
          flash[:notice] = "Authorized with Fire Eagle!"
          format.html { redirect_to profile_locations_path }
          format.mobile { redirect_to settings_path }
        else
          flash[:error] = "Failed to authorize with Fire Eagle.."
          format.html { redirect_to fireeagle_path }
          format.mobile { redirect_to fireeagle_settings_path }
        end      
      end
    else
      flash[:error] = "Something went wrong while activiating Fire Eagle. Please try again."
      redirect_to fireeagle_settings_path
    end
  end
  
  def fireeagle_activate
    client = FireEagle::Client.new(
        :consumer_key => "RJJovC4LM00S",
        :consumer_secret => "MRGkmWR6MaCxxBrNFxcdaQ63kxMs6KMZ",
        :access_token => "9Iu7mRFqCHSu",
        :access_token_secret => "o3D9RTkf3hegdDnla2PS0LKMXGnSwMZf"
    )
    token = client.get_request_token
    @u.update_attributes(:fireeagle_request_token => token.token, :fireeagle_request_token_secret => token.secret, :fireeagle_access_token => nil, :fireeagle_access_token_secret => nil)
    redirect_to client.authorization_url
    # @u.settings.get_fireeagle_request_token
    # redirect_to @u.settings.fireeagle_authorization_url
  end
  
  def twitter
  end
  
  def twitter_options
   #   OAuth::Consumer.new("0oLi2yJj2m119jdfUNON2w", "8XHGJZ6FNydGAN8Hgc54dA5yvWxF7EBXIaZXCw3ujg",{ :site=>"http://twitter.com/oauth/authorize" })
    #  OAuth::Consumer.new("MyYBKICB6Oe9XyQmYMui2g", "A7w8JjWu0SDnhMEHbGANri0CxQCfIjt6Dokjk3ouA",{:site=>"http://twitter.com/oauth/authorize"})
  end
  
  def twitter_off
  #  @u.settings.update_attributes(:twitter_login => nil, :twitter_password => nil)
    @u.settings.update_attributes(:twitter_login => nil, :twitter_password => nil, :twitter_oauth_token => nil , :twitter_oauth_secret => nil, :send_status_to_twitter => 0)
    flash[:notice] = "Status updates will no longer be sent to Twitter"
    redirect_to settings_path
  end
  
  def twitter_do
    @u.settings.send_status_to_twitter = params[:send_status] || false
    @u.settings.save!
    flash[:notice] = "Your Twitter settings have been updated"
    redirect_to twitter_options_settings_path
  end
  
  def twitter_key
    if @u.settings.validate_twitter_login(params[:login], params[:password])
      flash[:notice] = "Your Twitter credentials have been validated, all profile status updates will be pushed to your Twitter timeline."
      @u.settings.update_attributes(:twitter_login => params[:login], :twitter_password => params[:password])
    else
      flash[:error] = 'Incorrect Twitter username or password. Please try again.'
    end
    redirect_to twitter_options_settings_path
  end
  
  def twitter_requestauth
    oauth = @u.oauth
    session['rtoken'] = oauth.request_token.token
    session['rsecret'] = oauth.request_token.secret
    redirect_to oauth.request_token.authorize_url
  end
  
  def twitterauth
     
    oauth = @u.settings.oauth
    oauth.authorize_from_request(session['rtoken'], session['rsecret'], params[:pin])
    session['rtoken'] = nil
    session['rsecret'] = nil    
    @u.settings.update_attributes({
      :twitter_oauth_token => oauth.access_token.token, 
      :twitter_oauth_secret => oauth.access_token.secret,
    })
    flash[:notice] = "You have been successfully authorized with Twitter "
    redirect_to twitter_options_settings_path
  rescue => e
    HoptoadNotifier.notify(e)
    flash[:error] = "There was a problem authorizing you with Twitter, please try again"
    redirect_to twitter_settings_path
  end
    
  def facebook
    logger.debug request.class
    logger.debug request
  end
  
  def facebook_autho
    @api_key = YAML.load_file(File.join(RAILS_ROOT, "config", "facebooker.yml"))[RAILS_ENV]["api_key"]
    #facebook_settings = YAML::load(File.open("#{RAILS_ROOT}/config/facebooker.yml"))
    redirect_to "https://graph.facebook.com/oauth/authorize?client_id=#{@api_key}&redirect_uri=http://7.am/settings/facebook_oauth_callback&scope=offline_access,user_status,manage_pages,user_photos,user_videos,read_stream,publish_stream,user_about_me,friends_about_me,user_activities,friends_activities,user_birthday,friends_birthday,user_events,friends_events,user_groups,friends_groups,user_hometown,friends_hometown,user_interests,friends_interests,user_photos,friends_photos,user_relationship_details,friends_relationship_details,user_status,friends_status,user_videos,friends_videos,read_friendlists,manage_friendlists&display=wap" 
    #@fbuser = facebook_session.user
  end

  def facebook_off
    @u.settings.update_attributes(:facebook_infinite_session => nil, :facebook_uid => nil, :send_status_to_facebook  => 0)
    flash[:notice] = "Status updates will no longer be sent to Facebook"
    redirect_to settings_path
  end
  
  def facebook_options
    # flash.now[:notice] = "<h3>Authenticated to Facebook</h3>If you were redirected from status updates, " +
    #   "please <a href=\"#{profile_profile_statuses_path(@p)}\">click here</a> to go back. " +
    #   "If you were redirected from photos, please <a href=\"#{profile_photos_path(@p)}\">click here</a>"
    @api_key = YAML.load_file(File.join(RAILS_ROOT, "config", "facebooker.yml"))[RAILS_ENV]["api_key"]
    #facebook_settings = YAML::load(File.open("#{RAILS_ROOT}/config/facebooker.yml"))
    #redirect_to #"https://graph.facebook.com/oauth/authorize?type=client_cred&client_id=#{@api_key}&redirect_uri=http://180.149.241.251::8080/settings/facebook#_oauth_callback&scope=user_photos,manage_pages,user_videos,publish_stream&display=page" 
   # @fbuser = facebook_session.user
  end
  
  def facebook_oauth_callback
       if not params[:code].nil?
       @code = params[:code]
         facebook_settings = YAML::load(File.open("#{RAILS_ROOT}/config/facebooker.yml"))
	 callback = "http://7.am/settings/facebook_oauth_callback"
         @app_key = YAML.load_file(File.join(RAILS_ROOT, "config", "facebooker.yml"))[RAILS_ENV]["application_id"]
         url = URI.parse("https://graph.facebook.com/oauth/access_token?client_id=#{@app_key}&redirect_uri=http://7.am&client_secret=#{facebook_settings[RAILS_ENV]['secret_key']}&type=client_cred&code=#{CGI::escape(params[:code])}")
         http = Net::HTTP.new(url.host, url.port)
         http.use_ssl = (url.scheme == 'https')
         tmp_url = url.path+"?"+url.query
         request = Net::HTTP::Get.new(tmp_url)
         response = http.request(request)    
         data = response.body
         @usr_id = params[:code].split("-")[1].split("|")[0] 
	 @facebook_session = params[:code].split('|')[0]
         access_token = data.split("=")[1]
         @access_token = data.split("=")[1]
	  
      @u.settings.update_attributes(
      :facebook_uid => @usr_id, 
      :facebook_infinite_session => @facebook_session,
      :facebook_access_token => data,
      :facebook_session_expired => 0
      )

     # @u.settings.send_status_to_facebook = 1 
     # @u.settings.upload_photos_to_facebook = 1 
     # RAILS_DEFAULT_LOGGER.debug @u.settings.inspect
     # @u.settings.save!
      
      flash[:notice] = "We have saved your Facebook authorization key"
      
     # redirect_to welcome_path
       redirect_to facebook_options_settings_path
      end
     
     
  end

  def facebook_do
    @u.settings.send_status_to_facebook = params[:send_status] || false
    @u.settings.upload_photos_to_facebook = params[:upload_photos] || false
    RAILS_DEFAULT_LOGGER.debug @u.settings.inspect
    @u.settings.save!
    if @u.settings.send_status_to_facebook? || @u.settings.upload_photos_to_facebook?
      redirect_to welcome_path
    else
      flash[:notice] = "Your Facebook settings have been updated"
      redirect_to facebook_options_settings_path
    end
  end
  
  def facebook_extended_auth
    # flash[:notice] = "<h3>You are now authorized with Facebook</h3>We requested authorization to share your content successfully"
    # redirect_to :action => :facebook_key
    # redirect_to facebook_options_settings_path
    ensure_has_publish_stream(:next => facebook_extended_read_auth_settings_url)
    # redirect_to facebook_extended_read_auth_settings_url
  end
  
  def facebook_extended_read_auth
    # flash[:notice] = "<h3>You are now authorized with Facebook</h3>We requested authorization to share your content successfully"
    # redirect_to facebook_options_settings_path
    ensure_has_read_stream(:next => facebookauth_url)
  end
  
  def facebookauth
    flash[:notice] = "<h3>You are now authorized with Facebook</h3>We requested authorization to share your content successfully"
    # redirect_to :action => :facebook_key
    redirect_to (session[:facebook_redirect]) ? session[:facebook_redirect] : facebook_options_settings_path
  end
  
  def facebook_key
    config = YAML.load_file(File.join(RAILS_ROOT, "config", "facebooker.yml"))[RAILS_ENV]
    facebook_session.auth_token = params[:key]
    facebook_session.secure!
    @u.settings.update_attributes(
      :facebook_uid => facebook_session.user.uid, 
      :facebook_infinite_session => facebook_session.session_key,
      :facebook_session_expired => false
      )
    flash[:notice] = "We have saved your Facebook authorization key"
    redirect_to :action => :facebook_options
  end
  
  private
  
  def allow_to
    super :user, :all => true
  end
  
  def get_fbuser
    @fbuser = facebook_session.user
    # test for session expiry
    @fbuser.name
  rescue Facebooker::Session::SessionExpired
    flash.now[:notice] = <<-FB
      <h3>Facebook Authorization Expired</h3>Your Facebook authorization has
      expired. Please request an authorization key again
      FB
    @u.settings.expire_facebook_session!
    clear_facebook_session
    handle_facebook_auth
  end
  
end
