class FriendsController < ApplicationController
  
  # prepend_before_filter :get_profile
  skip_filter :store_location, :only => [:create, :destroy]  
  
  def create
    respond_to do |wants|
      if Friend.make_friends(@p, @profile)
        friend = @p.reload.friend_of? @profile
        wants.js {render( :update ){|page| page.replace @p.dom_id(@profile.dom_id + '_friendship_'), get_friend_link( @p, @profile)}}
        wants.mobile { redirect_to @profile }
      else
        message = "Oops... That didn't work. Try again!"
        wants.js {render( :update ){|page| page.alert message}}
        wants.mobile do
          flash[:error] = message
          redirect_to @profile
        end
      end
    end
  end
  
  
  def destroy
    @target = get_profile_from_login(params[:id])
    Friend.reset @p, @target
    respond_to do |wants|
      following = @p.reload.following? @target
      wants.js {render( :update ){|page| page.replace @p.dom_id(@target.dom_id + '_friendship_'), get_friend_link( @p, @target)}}
      wants.mobile { redirect_to @target }
    end
  end

 def active_chat
end  
  
  def index
    @latest_profile_page = params[:latest_profile_page] || 1
    @popular_profile_page = params[:popular_profile_page] || 1
    @latest_profiles = Profile.latest_profiles(@latest_profile_page)
    @popular_profiles = Profile.popular_profiles(@popular_profile_page)
    @friends_req = @p.wanna_be_friends_with_me.paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html { render }
      format.mobile
    end
  end
  
  def online_friends
    respond_to do |format|
      format.mobile do
        @friends = @p.online_friends.paginate(:page => params[:page], :per_page => 20)
        @title = "Online Friends"
        render :action => :friends
      end
    end
  end
  
  def everyone_online
    respond_to do |format|
      format.mobile do
        @friends = Profile.online_users.paginate(:page => params[:page], :per_page => 20)
        @title = "All Online Users"
        render :action => :friends
      end
    end
  end

  def friends
    respond_to do |format|
      format.mobile do
        @friends = @p.friends.paginate(:page => params[:page], :per_page => 20)
	@friends_req = @p.wanna_be_friends_with_me.paginate(:page => params[:page], :per_page => 20)
        @title = 'Friends'
      end
    end
  end
  
  def requests
    respond_to do |format|
      format.mobile do
        @friends = @p.wanna_be_friends_with_me.paginate(:page => params[:page], :per_page => 20)
        @title = 'Friend Requests'
	@feed_items = @p.feed_items.paginate(:all, :conditions => "item_type= 'Friendship'", :order => 'created_at desc', :page => params[:page], :per_page => 20)

	render :action => :friends
      end
    end
  end

  def followers
    respond_to do |format|
      format.mobile do
        @friends = @p.followers.paginate(:page => params[:page], :per_page => 20)
        @title = 'Followers'
        render :action => :friends
      end
    end
  end

  def followings
    respond_to do |format|
      format.mobile do
        @friends = @p.followed.delete_if{|f|@p.friend_of?(f)}.paginate(:page => params[:page], :per_page => 20)
        @title = 'Following'
        render :action => :friends
      end
    end
  end
  
  protected
  
  def allow_to
    super :owner, :all => true
  end  
    
end
