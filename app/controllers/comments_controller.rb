class CommentsController < ApplicationController
  
  skip_filter :store_location, :only => [:create, :destroy]
  before_filter :setup

  def create_comment
    @comment = Comment.create(params[:comment])
  end

  def more_profile_status_comments
    @status = ProfileStatus.find(params[:profile_status_id])
    @comments = @status.comments.find(:all, :order => 'created_at asc')
    respond_to do |format|
      format.js
    end
  end
  
  def index
    @comments = Comment.between_profiles(@p, @profile).paginate(:page => @page, :per_page => @per_page)
    redirect_to @p and return if @p == @profile
    respond_to do |wants|
      wants.html {render}
      wants.rss {render :layout=>false}
    end
  end

  def new
    respond_to do |format|
      format.mobile do
        @comment = @parent.comments.new
      end
    end
  end
  
  def create
    @comment = @parent.comments.new(params[:comment].merge(:profile_id => @p.id))
    
    respond_to do |wants|
      if @comment.save
        wants.mobile do
          flash[:notice] = "Your comment was posted successfully"
          redirect_to [@profile, @parent]
        end
        wants.js do
          render :update do |page|
            page.insert_html :top, "#{dom_id(@parent)}_comments", :partial => 'comments/comment'
            page.visual_effect :highlight, "comment_#{@comment.id}".to_sym
            page << 'tb_remove();'
            page << "jq('#comment_comment').val('');"
          end
        end
      else
        wants.mobile do
          # flash[:error] = "<h3>Comment could not be saved</h3>Please try again"
          render :action => :new
        end
        wants.js do
          render :update do |page|
            page << "message('Oops... I could not create that comment');"
          end
        end
      end
    end
  end
  
  protected
    
  def parent; @global_feed_item ||@blog || @profile_status || @photo || @location || @profile || nil; end
    
  def setup
    get_profile
    @user = @profile.user if @profile
    @profile_status = ProfileStatus.find(params[:profile_status_id]) if params[:profile_status_id]
    @photo = Photo.find(params[:photo_id]) if params[:photo_id]
    @location = Location.find(params[:location_id]) if params[:location_id]
    @blog = Blog.find(params[:blog_id]) unless params[:blog_id].blank?
    @global_feed_item = GlobalFeedItem.find(params[:global_feed_item_id]) if params[:global_feed_item_id]
    @parent = parent
  end
  
  def allow_to
    super :user, :only => [:index, :create, :new]
  end

end
