class FacebookController < ApplicationController

# before_filter :ensure_authenticated_with_facebook
# append_before_filter :got_twitter_login_name


def getprofile
  begin
  username = params[:username]
  @facebokstauses = FacebookStatus.find_by_name(username)
  @user_info = Settings.find_by_user_id(@p.user_id)
  config = YAML.load_file(File.join(RAILS_ROOT, "config", "facebooker.yml"))[RAILS_ENV]
  fb = Facebooker::Session.create(config['api_key'], config['secret_key'])
  @user = fb.post('facebook.users.getInfo', :session_key => @u.settings.facebook_infinite_session, :uids => @facebokstauses.facebook_uid, :fields => "name,pic_square,first_name,birthday,current_location,profile_url,sex")
     
  @user_friends = fb.post('facebook.friends.get', :session_key => @u.settings.facebook_infinite_session, :uids => @facebokstauses.facebook_uid).paginate(:page => params[:page], :per_page => 20)
  rescue

  end
end


  private
       
    def allow_to
      super :user, :all => true
    end
  

end
