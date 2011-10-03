require 'test_helper'
require 'action_controller'
require 'action_controller/test_process'

class ApplicationController; def rescue_action(e) raise e; end; end

UA = {
  :iphone => "Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_2_1 like Mac OS X; en-us) AppleWebKit/525.18.1 (KHTML, like Gecko) Version/3.1.1 Mobile/5H11 Safari/525.20",
  :n73 => "NokiaN73-1/4.0735.3.0.2 Series60/3.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 UP.Link/6.3.1.12.0"
}

class MobileActiveTest < ActionController::TestCase
  def setup
    @controller = WelcomeController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_nokia_n73
    @request.user_agent = UA[:n73]
    get :index
    assert_not_nil assigns['device']
    assert_equal 'Nokia', assigns['device'].brand
    assert_equal 'N73', assigns['device'].model
  end
  
  def test_iphone
    @request.user_agent = UA[:iphone]
    get :index
    assert_not_nil assigns['device']
    assert_equal 'Apple', assigns['device'].brand
    assert_equal 'iPhone', assigns['device'].model
  end
  
end
