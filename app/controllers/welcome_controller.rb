class WelcomeController < ApplicationController

  before_filter :preload_feed_item_models, :only => [:index, :public]
    
  def public
    @active = :public_stream
    @subdomain = current_subdomain
    respond_to do |format|
      format.mobile do
        @profile = @p
        @feed_items = PublicFeedItem.paginate(:order => 'created_at desc', :page => params[:page], :per_page => 20)
      end
    end
  end
    
  def index
    @id = params[:id]
    @active = :my_stream
    session[:alerted] = false
    respond_to do |format|
      format.mobile do
        @profile = @p
        @feed_items = @p.feed_items.paginate(:all, :order => 'created_at desc', :page => params[:page], :per_page => 20)
            
      end
    end
  end
  
  def twitter
    @active = :twitter
    session[:alerted] = false
    respond_to do |format|
      format.mobile do
        @profile = @p
	@feed_items = @p.feed_items.paginate(:all, :conditions => "item_type = 'TwitterStatus'",:order => 'created_at desc', :page => params[:page], :per_page => 20)
        @results = @profile.followed.paginate(:page => params[:page], :per_page => 20)
	
   #	render :action => :index    
	
      end
    end
  end
  
  def facebook
    @active = :facebook
    session[:alerted] = false
    respond_to do |format|
      format.mobile do
        @profile = @p
       # @feed_items = @p.feed_items.paginate(:all, :order => 'created_at desc', :page => params[:page], :per_page => 20)
         @feed_items = @p.feed_items.paginate(:all, :conditions => "item_type = 'FacebookStatus'",:order => 'created_at desc', :page => params[:page], :per_page => 20)
	
	#@feed_items = ProfileStatus.paginate(:all, :conditions => "facebook_status_id != 'null' && profile_id='#{@p.id}'", :order => 'created_at desc', :page => params[:page], :per_page => 20)
      # render :action => :index
      end
    end
  end
  
  def seven_stream
    @active = :seven_stream
    session[:alerted] = false
    respond_to do |format|
      format.mobile do
        @profile = @p
	#all your streams 
	@feed_items = @p.feed_items.paginate(:all, :conditions => "item_type = 'ProfileStatus'",:order => 'created_at desc', :page => params[:page], :per_page => 20)

	#all your frends streams 
	#@friends_streams = @p.friends.paginate(:page => params[:page], :per_page => 20)
	#@friends_streams.each do |frnd_stream|
	  # @frnd_prof = Profile.find(frnd_stream.id)
	  # @feed_items << @frnd_prof.feed_items.paginate(:all, :conditions => "item_type = 'ProfileStatus'",:order => 'created_at desc', :page => params[:page], :per_page => 20)
	#end
       # render :action => :index
      end
    end
  end

  def main_menu
    respond_to do |format|
      format.mobile do
        @feed_items = []
        @user_count = User.count if @u.is_admin?
      end
    end
  end
  
  private
  
  def allow_to
    super :user, :all => true
  end
    
end

