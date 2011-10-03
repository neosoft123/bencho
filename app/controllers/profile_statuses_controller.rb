class ProfileStatusesController < ApplicationController

  include LocationisedController
  include ShortlinksHelper

  # prepend_before_filter :get_profile
  #before_filter :create_friends_map, :only => [:show, :index]
  
  before_filter :ensure_authenticated_to_facebook, :only => [ :facebook_send ]
  # before_filter :ensure_has_status_update, :only => [ :facebook_send ]
  skip_filter :store_location, :only => [:create, :destroy, :facebook_send, :twitter_send]

  def index
    
    handle_facebook_auth if @u.settings.send_status_to_facebook? 
    
    respond_to do |format|
      format.html do
        @statuses = @profile.profile_statuses.find(:all, :limit => 20, :order => 'created_at desc')
        render :layout => 'new_application'
      end

      format.xml { render :xml => @statuses, :status => 200, :location => profile_profile_statuses_url(@profile) }

      format.atom { render :layout => false }

      format.mobile do
        @statuses = @profile.profile_statuses.find(:all, :limit => 5, :order => 'created_at desc')
      end

    end
  end

  def show
    @status = ProfileStatus.find(params[:id])
    respond_to do |format|
      format.html
      format.xml { render :xml => @status, :status => 200, :location => profile_profile_status_url(@profile, @status) }
      format.mobile
    end
  end

  def new
    @status = @profile.profile_statuses.new(:text => params[:status] + " ")
    respond_to do |format|
      format.mobile
      format.xml { render :xml => @status, :status => 200, :location => new_profile_profile_status_url(@profile) }
    end
  end
  
  def create
    @status = @profile.profile_statuses.new(params[:profile_status])
    respond_to do |format|
      last_status = @profile.profile_statuses.current rescue nil # avoid double-postings
      if last_status.nil? || @status.text != last_status.text
        if @status.save
          format.js do
            if params[:profile_page] and params[:profile_page] == "true"
              @feed_item = FeedItem.for_profile_status(@status).first
              render :template => 'profile_statuses/create_on_profile'
            else
              render
            end
          end
          format.mobile do
            if((params[:twitter_flag] == "1") && (params[:facebook_flag] == "1"))	      
	     if @u.settings.send_status_to_twitter?
	        session[:set_facebook] = "no"
	        redirect_to twittersend_path(@p, @status)
             else
	       if @u.settings.send_status_to_facebook?
		  session[:set_facebook] = "yes"
                  redirect_to facebooksend_path(@p, @status)
               else
	          flash[:notice] = 	"<h3>Your status has been updated</h3>"
		  redirect_to welcome_path
	       end 
	     end
	    elsif(params[:twitter_flag] == "1")
	      if @u.settings.send_status_to_twitter? 	       	 
	         redirect_to twitterstatus_path(@p, @status)
              else
	         flash[:notice] = 	"<h3>Your status has been updated</h3>"
		 redirect_to welcome_path
	      end
	    elsif(params[:facebook_flag] == "1")
	      if @u.settings.send_status_to_facebook?
	         session[:set_facebook] = "yes"
                 redirect_to facebooksend_path(@p, @status)
              else
	         flash[:notice] = 	"<h3>Your status has been updated</h3>"
		 redirect_to welcome_path
	      end
	     
	    else
              flash[:notice] = 	"<h3>Your status has been updated</h3>"
              redirect_to welcome_path
            end
          end
        else
          format.mobile do
            flash[:error] = "Something went wrong while setting your status, please try again"
            redirect_to welcome_path
          end
        end
      else
        format.mobile do
          redirect_to welcome_path
        end
      end
    end
  rescue => e
    raise e if RAILS_ENV == "development"
    HoptoadNotifier.notify(e)
    flash[:error] = "There was a problem posting your status update, we're looking into it"
    redirect_to welcome_path
  end
  
  def twitterpost
    @u.settings.tweet ProfileStatus.find(params[:id]).text
      set_twitterflash
      redirect_to welcome_path
     rescue => e
    HoptoadNotifier.notify(e)
    flash[:error] = "There was a problem updating your Twitter status, we're looking into it"
    redirect_to welcome_path
  end

  
  def twitter_send
     @u.settings.tweet ProfileStatus.find(params[:id]).text
     @profiletwstatuses =  ProfileStatus.find(params[:id])
     @profiletwstatuses.twitter_post_status = 1
     @profiletwstatuses.save
    if @u.settings.send_status_to_facebook?
      redirect_to facebooksend_path(@p, @p.profile_statuses.find(params[:id]))
    else
      set_flash
      redirect_to welcome_path
    end
  rescue => e
    HoptoadNotifier.notify(e)
    flash[:error] = "There was a problem updating your Twitter status, we're looking into it"
    redirect_to welcome_path
  end
  
  def facebook_send
    fbuser = facebook_session.user
    # fbuser.set_status shortlinkify(ProfileStatus.find(params[:id]).text)
     fbuser.set_status ProfileStatus.find(params[:id]).text   
     @profilefbstatuses =  ProfileStatus.find(params[:id])
     @profilefbstatuses.fb_post_status = 1
     @profilefbstatuses.save

    if(session[:set_facebook] == "yes")
      set_facebkflash
    else
     if(session[:set_facebook] == "no")     
      set_flash
    end
    end
    # redirect_to url_for(:action => :index)
    session[:set_facebook] = "null"
    redirect_to public_stream_path
  rescue => e
    HoptoadNotifier.notify(e)
    flash[:error] = "There was a problem updating your Facebook status, we're looking into it"
    redirect_to public_stream_path
  end
  
   

  def  set_twitterflash
    services = []
   #services << '<a href="http://www.twitter.com">Twitter</a>' if @u.settings.send_status_to_twitter?
    message = "<h3>Your status has been updated</h3>"
    message << "Your status has also been updated on Twitter" 
    flash[:notice] = message
  end

  def set_facebkflash
    #services << '<a href="http://m.facebook.com">Facebook</a>' if @u.settings.send_status_to_facebook?
    message = "<h3>Your status has been updated</h3>"
    message << "Your status has also been updated on Facebook"
    flash[:notice] = message
  end
        

  def set_flash
    services = []
    services << '<a href="http://www.twitter.com">Twitter</a>' if @u.settings.send_status_to_twitter?     
    services << '<a href="http://m.facebook.com">Facebook</a>' if @u.settings.send_status_to_facebook?
    message = "<h3>Your status has been updated</h3>"
    message << "Your status has also been updated on #{services.join(' and ')}" if services.length > 0
    flash[:notice] = message
  end
  
  def destroy
    ProfileStatus.find(params[:id]).destroy
    flash[:notice] = "Profile status deleted"
    redirect_to :action => :index
  end
  
  protected
  
  def allow_to
    super :owner, :all => true
    super :user, :only => [:show]
  end

end
