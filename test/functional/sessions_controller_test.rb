require File.dirname(__FILE__) + '/../test_helper'
require 'shoulda'
include AuthenticatedTestHelper

class SessionsControllerTest < ActionController::TestCase

  VALID_USER = {
    :login => 'lquire',
    :email => 'lquire@example.com',
    :password => 'lquire', :password_confirmation => 'lquire',
    :terms_of_service=>'1'
  }
  
  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_login_and_redirect
    u = User.authenticate('user', 'test')  
    post :create, {:login => 'user', :password => 'test'}
    assert session[:user]
    assert assigns['u']
    assert_response :redirect
    assert_redirected_to profile_path(assigns['u'].profile)
  end

  def test_should_fail_login_and_redirect_with_message
    post :create, {:login => 'user', :password => 'bad password'}
    assert_nil session[:user]
    assert_template 'new'
    assert_equal "Uh-oh, logging in with 'user' didn't work. Do you have caps locks on? Try it again.", flash[:error]
  end
  
  def test_forgot_no_email
    flashback
    post :forgot_password, {:email=>'asdf'}
    assert_nil session[:user]
    assert_redirected_to :action => :new
    assert_equal nil, flash[:notice]
    assert_equal "Could not find that email address. Try again.", flash.flashed[:error] 
  end
  
  
  
  def test_forgot_good_email
    flashback
    assert u = users(:user)
    assert p = u.crypted_password
    post :forgot_password, :email=>profiles(:user).email
    assert_nil session[:user]
    assert_redirected_to :action => :new
    assert_equal nil, flash[:error] 
    assert_equal "A new password has been mailed to you.", flash.flashed[:notice] 
    assert_not_equal(assigns(:p), u.crypted_password)
  end
 
  def test_should_logout
    login_as :user
    get :destroy
    assert_nil session[:user]
    assert_response :redirect
    assert_redirected_to home_url
  end

  def test_should_remember_me
    post :create, {:login => 'user', :password => 'test', :remember_me => "1"}
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :create, {:login => 'quentin', :password => 'test', :remember_me => "0"}
    assert_response :success
    assert @response.cookies["auth_token"] == []
  end
  
  def test_should_delete_token_on_logout
    login_as :user
    get :destroy
    assert_equal [], @response.cookies["auth_token"]
  end

  def test_should_login_with_cookie
    users(:user).remember_me
    @request.cookies["auth_token"] = cookie_for(:user)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:user).remember_me
    users(:user).update_attribute :remember_token_expires_at, 5.minutes.ago.utc
    @request.cookies["auth_token"] = cookie_for(:user)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:user).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def create_user(options = {}, signup_code = '1234')
      post :signup, {:user => { :login => 'lquire', :email => 'lquire@example.com',
        :password => 'lquire', :password_confirmation => 'lquire', :terms_of_service => '1' }.merge(options)}
    end
    
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
