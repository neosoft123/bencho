class BlogsController < ApplicationController

  def index
    respond_to do |wants|
      wants.html {render}
      wants.rss {render :layout=>false}
      wants.mobile { render }
    end
  end
  
  def create
    @blog = @p.blogs.build params[:blog]
    
    respond_to do |wants|
      if @blog.save
        wants.mobile do
          flash[:notice] = "New diary entry created"
          redirect_to profile_blogs_path(@p)
        end
      else
        wants.mobile do
          flash.now[:error] = 'Failed to create your diary entry'
          render :action => :new
        end
      end
    end
  end
  
  def show
    respond_to do |format|
      format.mobile do
        @blog = @profile.blogs.find(params[:id])
      end
    end
  end
    
  def update
    respond_to do |wants|
      if @blog.update_attributes(params[:blog])
        wants.html do
          flash[:notice]='Blog post updated.'
          redirect_to profile_blogs_path(@p)
        end
      else
        wants.html do
          flash.now[:error]='Failed to update the blog post.'
          render :action => :edit
        end
      end
    end
  end
  
  def destroy
    @p.blogs.find(params[:id]).destroy
    respond_to do |wants|
      wants.mobile do
        flash[:notice]='Diary entry post deleted'
        redirect_to profile_blogs_path(@p)
      end
    end
  end

  protected  
  
  def allow_to
    super :owner, :all => true
    super :all, :only => [:index, :show]
  end
  
end
