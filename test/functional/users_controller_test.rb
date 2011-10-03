require File.dirname(__FILE__) + '/../test_helper'

module ActionController
  class TestRequest < AbstractRequest
    attr_accessor :user_agent
  end
end

class UsersControllerTest < ActionController::TestCase

  VALID_USER = {
    :login => 'lquire',
    :email => 'lquire@example.com',
    :password => 'lquire', :password_confirmation => 'lquire',
    :terms_of_service=>'1'
  }
  
  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    setup_mobile
  end
  
   
  def test_should_use_msisdn_passthrough
    # HTTP_X_UP_CALLING_LINE_ID
    @request.env['HTTP_X_UP_CALLING_LINE_ID'] = '27825559629'
    get :new 
    assert_response :success
    puts assigns[:phone_number]
    assert assigns[:phone_number] == '0825559629'
  end
  
  def test_should_use_phone_number_if_only_provided
    get :new, {:phone_number => '27825559629'}
    assert_response :success
    puts assigns[:phone_number]
    assert assigns[:phone_number] == '0825559629'
  end
  
  def test_msisdn_passthrough_should_override
    @request.env['HTTP_X_UP_CALLING_LINE_ID'] = '27825559629'
    get :new, {:phone_number => '278212345678'}
    assert_response :success
    puts assigns[:phone_number]
    assert assigns[:phone_number] == '0825559629'
  end
  
 protected
   def create_user(options = {}, signup_code = '1234')
     post :create, {:user => { :login => 'lquire', :email => 'lquire@example.com',
       :password => 'lquire', :password_confirmation => 'lquire', :terms_of_service => '1' }.merge(options)}
   end
   
   def setup_mobile
     @request.user_agent = "SonyEricssonW580i/R8BE Browser/NetFront/3.3 Profile/MIDP-2.0 Configuration/CLDC-1.1 UP.Link/6.3.1.12.0"
   end

end