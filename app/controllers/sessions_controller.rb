require 'uuidtools'

# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout :plain
  include MobilisedController

  before_filter :login_required, :only => [ :destroy ]
  skip_filter :store_location
  skip_filter :setup_chat
  skip_filter :load_online_friends
 # before_filter :get_all_online
  
  layout 'plain'
  
  def new
    # flash.now[:error] = render_to_string :partial => 'shared/alpha_message'
    @user = User.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml
      format.mobile
    end
  end

  def create
    @user = User.new
    logout_keeping_session!
    @user = User.authenticate(params[:user][:login], params[:user][:password])
    
    if @user.nil?
      # Auth Failed
      note_failed_signin
      @login       = params[:user][:login]
      @remember_me = params[:remember_me]
      @user = User.new(:login => params[:user][:login])
      @show_login = true
            
      respond_to do |format|
        format.html { redirect_to current_user.profile }
        format.mobile do
          flash.now[:error] = render_to_string :partial => "login_failed"
          render :action => :new
        end
      end
      return
    else
      # Auth successful
      self.current_user = @user
      set_cookies
     
      begin
        @user.signon(params[:user][:password])
      rescue DRb::DRbConnError => e
        flash[:error] = "Everything not cricket with the chat server. Please check back soon."
      end
      @user.update_attribute('login_count', 2)
      set_profile
       if @user.admin_account == true
            redirect_to admin_path
       else
      # @user.update_locations_from_fireeagle if @user.settings.authorized_with_fireeagle?
      password_recently_changed
      
      respond_to do |format|
        format.html do 
          if params[:return_to]
            redirect_to(params[:return_to])
          else
                 redirect_to(@user.profile) 
          end
        end
        format.xml
        format.mobile { 
          if @user.settings && @user.settings.facebook_session_expired
            flash[:notice] = <<-FB
              <h3>Facebook Authorization Expired</h3>Your Facebook authorization has
              expired. Please go to your Facebook settings from the menu and re-authorize 7.am
              FB
          end
          redirect_to(@user.profile)
        }
      end
    end
end
  end
  
  before_filter :preload_feed_item_models, :only => [:preview, :admin_login]
    
  def preview
    @active = :preview
    @subdomain = current_subdomain
    respond_to do |format|
      format.mobile do
        @profile = @p
        @feed_items = PublicFeedItem.paginate(:order => 'created_at desc', :page => params[:page], :per_page => 20)
      end
    end    
  end
  
 
  def admin_login
 

    @user = User.new
 
 @active = :preview
    @subdomain = current_subdomain
    respond_to do |format|
      format.mobile do
        @profile = @p
        @feed_items = PublicFeedItem.paginate(:order => 'created_at desc', :page => params[:page], :per_page => 20)
      end
    end    
  end
 
 def destroy
    @current_user.signout    
    logout_killing_session!
    
    flash[:notice] = "You have been logged out."
    
    if is_mobile_device?
      redirect_to preview_path
      return
    end
    redirect_to preview_path
  end
  
  def forgot_password
  end
 
  def send_reset_password
    unless User.exists?(:login => params[:login])
      flash[:error] = "<h3>Unknown login name</h3>Please enter your login name and try again"
      redirect_to(forgot_password_path)
    else
      u = User.find_by_login params[:login]
      u.update_attribute(:password_reset_code, UUID.random_create.to_s[0,8])
      message = render_to_string :partial => 'password_reset_message', :locals => { :user => u }
      if send_sms(u.profile.mobile, Shortlink.shortlinkify(message))
        flash[:notice] = "<h3>Request successful!</h3>An sms has been sent to your registered mobile number, please follow the directions it contains."
        redirect_to login_url
      else
        flash[:error] = "<h3>Request failed!</h3>An sms could not be sent to your registered mobile number, please try again"
        redirect_to forgot_password_url
      end
    end
  end
  
  def reset_password
    @u = User.find_by_password_reset_code(params[:code])
    unless @u
      flash[:error] = "<h3>Request failed!</h3>We could not find a valid password reset request for that request code"
      redirect_to forgot_password_url
    else
      @u.update_attribute(:password_reset_code, nil)
      render
    end
  end
  
  def reset_password_do
    user = User.find params[:user_id]
    if user
      new_password = params[:new_password]
      unless user.change_password(nil, new_password, new_password, false)
        message = "<h3>Password reset failed, please try again.</h3>"
        user.errors.each { |e| message += "<br/>" + e.join(" ") }
        flash.now[:error] = message
        @u = user
        render :action => :reset_password
      else
        flash[:notice] = "<h3>Password reset successful!</h3>Password was successfully changed, please login again."
        redirect_to login_url
      end
    else
      flash[:error] = "<h3>Password reset failed</h3>We could not reset your password. Please re-request a password reset"
    end
  end
  
  def mark_map_location
    session[:map_location] = { :lat => params[:lat] , :lng => params[:lng] }
    render :nothing => true
  end
  
protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Whoops that combo didnt work. Please try it again." unless is_mobile_device?
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
  def password_recently_changed
    if @user.password_reminder
      flash[:notice] = "Remember to update your password <a href='#{change_password_user_path(@user)}'>here</a>."
      @user.password_reminder = false
      @user.save(false)
    end
  end
  
  def set_cookies
    new_cookie_flag = params[:remember_me] ? true : false
    handle_remember_cookie! new_cookie_flag
    
    expiry = 1.week.from_now.to_i
    cookies[:tender_email] = { :value => @user.profile.email, :domain => ".7.am" }
    cookies[:tender_expires] = { :value => @expiry.to_s, :domain => ".7.am" }
    cookies[:tender_hash] = { :value => @user.tender_token(expiry), :domain => ".7.am" }
  end
  
  def allow_to
    super :owner, :all => true
    super :all, :all => true
  end
  
end
