class GlobalFeedItemsController < ApplicationController
  
  def index
    respond_to do |format|
      format.mobile { @feed_items = GlobalFeedItem.all }
    end
  end
  
  def new
    @feed_item = GlobalFeedItem.new
  end
  
  def create
    flash[:error] = "Temporarily disabled"
    redirect_to :action => :index
    # @feed_item = GlobalFeedItem.new(params[:global_feed_item])
    # @feed_item.profile = @p
    # if @feed_item.save
    #   redirect_to :action => :index
    # else
    #   flash[:error] = @feed_item.errors
    #   render :action => :new
    # end
  end
  
end
