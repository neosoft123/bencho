class FeedItemsController < ApplicationController
  
  skip_filter :store_location
  
  def destroy
    @profile.feeds.find(:first, :conditions => {:feed_item_id=>params[:id]}).destroy rescue nil

    respond_to do |wants|
      wants.html do
        flash[:notice] = 'Item successfully removed from the recent activities list.'
        redirect_back_or_default @profile
      end
      wants.js { render(:update){|page| page.visual_effect :puff, "feed_item_#{params[:id]}".to_sym}}
      wants.mobile do
        flash[:notice] = "Feed item deleted"
        redirect_back_or_default @profile
      end
    end
  end
  
  
  protected
  def allow_to
    super :owner, :only => [:destroy]
  end
  
end