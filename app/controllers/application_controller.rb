require 'aasm'

class ApplicationController < ActionController::Base
  helper :all

  # include HoptoadNotifier::Catcher
  include AuthenticatedSystem
  
  # audit Kontact, KontactInformation, PhoneNumber, Email, Wallet
  
  filter_parameter_logging :password
  
  # Mobile Plugins
  before_filter :remove_force_agent_unless_admin
  # has_mobile_fu #true
  
  prepend_before_filter :get_profile
  before_filter :allow_to, :check_user, :set_profile, :pagination_defaults, :check_permissions#, :user_count#, :peeping_tom, :get_all_online
  # before_filter :load_help
  append_before_filter :setup_chat
  after_filter :store_location
  before_filter :load_online_friends
  
  layout 'application'
  
  acts_as_mobile :force_mobile => true  
  
  def check_featured
    return if Profile.featured_profile[:date] == Date.today
    Profile.featured_profile[:date] = Date.today
    Profile.featured_profile[:profile] = Profile.featured
  end
  
  def pagination_defaults
    @page = (params[:page] || 1).to_i
    @page = 1 if @page < 1
    @per_page = (params[:per_page] || ((RAILS_ENV=='test') || (RAILS_ENV=='ci``') ? 1 : 40)).to_i
  end
  
def get_profile
    login = params[:profile_id] || params[:id]
    login = login.gsub(/\//, '') unless login.blank? # TODO total fucking hack
    @profile = get_profile_from_login(login) unless login.blank?
  rescue
    @profile = nil
  end
  
  
  def set_profile
    # KontactContext().profile = @p = @u.profile if @u
    @p = @u.profile if @u
    @p.update_attributes({ :last_activity_at => Time.now, :last_user_agent => request.user_agent }) if @p
  rescue DRb::DRbConnError => e
    @u.offline!
  end
  
  def setup_chat
    unless request.method == :post
      if @u && @p
        respond_to do |format|
          format.xml { return true }
          format.html { return true }
          format.mobile do
            @u.reload
            unless @u.online?
              @u.signout # just to make sure that we remove user from active users list
              RAILS_DEFAULT_LOGGER.debug "USER OFFLINE: will return them to #{request.request_uri}"
              session[:chat_return_to] = request.request_uri
              redirect_to chat_login_profile_path(@p)
            else
              @u.available
              if @p.chat_invitations.length > 0
                @chat_inviters = @p.chat_invitations.map{|inv|inv.destroy;inv.from}
                flash.now[:invite] = "You have chat invitations from "
              end
            end
          end
        end
      end
    else
      logger.debug "SKIPPING CHAT CHECK ON POST"
    end
  end
  
  def handle_facebook_auth
    session[:facebook_redirect] = request.request_uri
    ensure_authenticated_to_facebook
  end
  
  def clear_facebook_session
    @facebook_session = nil
    session[:facebook_session] = nil
  end
    
  def peeping_tom
    KontactContext().profile = current_user.profile if  ( current_user && current_user.class == User )
  end

  def my_profile
    @p
  end

  helper_method :my_profile
  
  helper_method :flickr, :flickr_images
  # API objects that get built once per request
  def flickr(user_name = nil, tags = nil )
    @flickr_object ||= Flickr.new(FLICKR_CACHE, FLICKR_KEY, FLICKR_SECRET)
  end
  
  def flickr_images(user_name = "", tags = "")
    unless RAILS_ENV == "test"# || RAILS_ENV == "development"
      begin
        flickr.photos.search(user_name.blank? ? nil : user_name, tags.blank? ? nil : tags , nil, nil, nil, nil, nil, nil, nil, nil, 20)
      rescue
        nil
      rescue Timeout::Error
        nil
      end
    end
  end
  
  def rescue_404
    render :template => "shared/error404", :status => "404"
  end

  # used for testing
  # def rescue_action_locally(exception)
  #   render :template => "shared/error", :status => "500"
  # end

  def rescue_action_in_public(exception)
    render :template => "shared/error", :status => "500"
  end
  
  protected
  
  def user_count
    @online_user_count = Rails.cache.fetch("user-count", :expires_in => 5.minutes) do
      DRbObject.new(nil, XMPP_CONFIG['drb_server']).online_user_count rescue 0
    end
  end
  
  def load_online_friends
    # for low-level phones load the online friends and message count straight away
    get_friends #if @wurfl_device #&& !@wurfl_device.supports_ajax?
  end
  
  def get_friends
    if @p && @u
      @online_friends = Rails.cache.fetch("#{@u.login}-online-friends", :expires_in => 30.seconds) do
        online_friends = {}
        @p.online_friends.each do |f|
          online_friends[f] = @u.jabber_messages.unread.from_profile(f).length
        end
        online_friends = online_friends.sort{ |a,b| b[1] <=> a[1] }
        online_friends
      end
    else
      @online_friends = {}
    end
  rescue => e
    HoptoadNotifier.notify(e)
    @online_friends = {}
  end
  
  def get_all_online
      @all_online = Profile.online_users
    rescue => e
      HoptoadNotifier.notify(e)
      @all_online = {}
  end
  
  def ensure_authenticated_with_twitter
     unless @u.settings.authorized_with_twitter?
     # @consumer =  OAuth::Consumer.new("0oLi2yJj2m119jdfUNON2w", "8XHGJZ6FNydGAN8Hgc54dA5yvWxF7EBXIaZXCw3ujg",{ :site=>"http://m.twitter.com" })  
     @consumer = OAuth::Consumer.new("MyYBKICB6Oe9XyQmYMui2g", "A7w8JjWu0SDnhMEHbGANri0CxQCfIjt6Dokjk3ouA",{:site=>"http://api.twitter.com/1/*"})
     @request_token = @consumer.get_request_token(:oauth_callback => "http://7.am/settings/twitterauth")
	session['rtoken'] = @request_token.token
	session['rsecret'] = @request_token.secret     
        redirect_to @request_token.authorize_url
     # oauth = @u.settings.oauth
     # session['rtoken'] = oauth.request_token.token
     # session['rsecret'] = oauth.request_token.secret
     # redirect_to oauth.request_token(:oauth_callback => "http://lg.localhost:3000/settings/twitterauth").authorize_url.gsub!(/http:\/\//, "http://m.") + "&callback_url=http://localhost:3000/settings/twitterauth"
    end

  end
  
#def ensure_authenticated_with_twitter
#    unless @u.settings.authorized_with_twitter?
#      oauth = @u.settings.oauth
#      session['rtoken'] = oauth.request_token.token
#      session['rsecret'] = oauth.request_token.secret
#      redirect_to oauth.request_token.authorize_url.gsub!(/http:\/\//, "http://m.")
#    end
#  end


  def mobile_or_html_file_ext
    return '.mobile.html' if is_mobile_device?
    return '.html'
  end
  
  def remove_force_agent_unless_admin
    if @force_html
      session[:force_agent] = :html
    else
      session[:force_agent] = nil
    end
  end
  
  def load_help
    @help = Help.find_by_controller_and_action(params[:controller], params[:action])
    return if @help.nil?
    
    if @help.has_been_show_to?(current_user)
      @help_has_been_shown = true
    else
      @help.has_now_been_shown_to!(current_user)
    end
  end
  
  def get_profile_from_login(login)
    User.find_by_login(login, :include => [:profile]).profile rescue nil
  end
  
  def allow_to level = :all, args = {:only => [:rescue_404, :rescue_action_in_public]}
    return unless level
    @level ||= [ [:all, {:only => [:rescue_404, :rescue_action_in_public, :rescue_action_in_public_without_hoptoad, :rescue_action_in_public_with_hoptoad]}] ]
    @level << [level, args]    
  end
  
  def check_permissions
    # logger.debug "IN check_permissions :: @level => #{@level.inspect}"
    return failed_check_permissions if @p && !@p.is_active
    return true if @u && @u.is_admin
    raise '@level is blank. Did you override the allow_to method in your controller?' if @level.blank?
    @level.each do |l|
      next unless (l[0] == :all) || 
        (l[0] == :non_user && !@u) ||
        (l[0] == :user && @u) ||
        (l[0] == :owner && @p && @profile && @p == @profile) ||
        (l[0] == :friend && @p && @profile && @p.friend_of?(@profile)) ||
        (l[0] == :follower && @p && @profile && @p.following?(@profile)) || 
        (l[0] == :editor && controller_instance.respond_to?(:is_owner?) && controller_instance.is_owner?(@p)) ||
        (l[0] == :member && @group && @p && (@group.is_member?(@p) || @group.is_owner?(@p))) ||
        (l[0] == :admin && @u && @u.is_admin?)
      args = l[1]
      @level = [] and return true if args[:all] == true
      
      if args.has_key? :only
        actions = [args[:only]].flatten
        actions.each{ |a| @level = [] and return true if a.to_s == action_name}
      end
      
      if args.has_key? :except
        actions = [args[:except]].flatten
        @level = [] and return true unless actions.include? action_name.to_sym
      end
    end
    if(!@p && session[:return_to]== nil)
      redirect_to preview_path
    elsif session[:return_to]
      redirect_to session[:return_to]
    else
      return failed_check_permissions
    end
  end
  
  def failed_check_permissions
    if RAILS_ENV != 'development'
      flash[:error] = 'It looks like you don\'t have permission to view that page.'
      #redirect_back_or_default home_path and return true
      redirect_to session[:return_to]
    else
      render :text=><<-EOS
      <h1>It looks like you don't have permission to view this page.</h1>       
      <div>
        Owner: #{@profile.user.login rescue ""}<br />
        Current User: #{@u.login rescue ""}<br />
        Permissions: #{@level.inspect}<br />
        Controller: #{controller_name}<br />
        Action: #{action_name}<br />
        Params: #{params.inspect}<br />
        Session: #{session.instance_variable_get("@data").inspect}<br/>
        Return To: #{session[:return_to]}
      </div>
      EOS
    end
    @level = []
    false
  end
  
  def preload_feed_item_models
    FeedItem
    Photo
    Location
    ProfileStatus
    PublicFeedItem
    Comment
    Group
    GroupInvitation
    GlobalFeedItem
    Followship
    FacebookStatus
    BusinessCardRequest
    BusinessCardProfile
    Blog
    Friendship
    Message
    TwitterStatus
    Friend
    ChatReminderMessage
    User
    Profile
  end

  private 
  
  def controller_instance 
    eval "@#{controller_name.singularize}"
  end

end
