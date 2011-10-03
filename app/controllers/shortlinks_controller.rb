class ShortlinksController < ApplicationController
  
  include ShortlinksHelper
  
  skip_filter :login_required
  
  def make
    @shortlink = Shortlink.new
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  def made
    @shortlink = Shortlink.create_or_find_shortlink params[:href]
    respond_to do |format|
      format.html { render :layout => false }
    end
  end
  
  def handle
    shortlink = Shortlink.find_by_href_code params[:href_code]
    if shortlink
      shortlink.update_attribute :click_count, shortlink.click_count + 1
      redirect_to shortlink.redirect_href
    else
      render(:file  => "#{RAILS_ROOT}/public/404#{mobile_or_html_file_ext}", :status => "404 Not Found")
    end
  end
  
  def allow_to
    super :all, :all=>true
  end
  
end
