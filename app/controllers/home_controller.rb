class HomeController < ApplicationController

  skip_before_filter :login_required
  skip_before_filter :set_mobile_format, :only => [:check, :users]
  
  def check
    head :ok
  end
  
  def users
    server = DRbObject.new nil, XMPP_CONFIG['drb_server']
    render :text => server.online_user_count.to_s
  end
  
  def device_check
    respond_to do |format|
      format.mobile do
        render :layout => 'plain'
      end
    end
  end

  def contact
    return unless request.post?
    body = []
    params.each_pair { |k,v| body << "#{k}: #{v}"  }
    HomeMailer.deliver_mail(:subject=>"from #{SITE_NAME} contact page", :body=>body.join("\n"))
    flash[:notice] = "Thank you for your message.  A member of our team will respond to you shortly."
    redirect_to contact_url    
  end

 
  def index
    @show_login = false
    # check_featured
    respond_to do |wants|
      wants.html do
        if current_user
          redirect_to profile_path(:id => current_user.profile)
        else
          @user = User.new
          # render :layout => 'new_home'
        end
      end
      wants.rss {render :partial =>  'profiles/newest_member', :collection => new_members}
      wants.mobile {
        if current_user
          redirect_to welcome_url
        else
          redirect_to preview_path
        end
      }
    end
  end

  def newest_members
    respond_to do |wants|
      wants.html {render :action=>'index'}
      wants.rss {render :layout=>false}
    end
  end
  def latest_comments
    respond_to do |wants|
      wants.html {render :action=>'index'}
      wants.rss {render :layout=>false}
    end
  end

  def terms
    render
  end


  private
  def allow_to 
    super :all, :all=>true
    super :non_user , :all => true
  end

end

class HomeMailer < ActionMailer::Base
  def mail(options)
    self.generic_mailer(options)
  end
end