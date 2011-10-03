require File.dirname(__FILE__) + '/../test_helper'

class ProfileControllerSearchTest < ActionController::TestCase
  tests ProfilesController

  context 'route generation should glob search' do
    should 'recognize a search query as a valid route' do
      assert_generates('/profiles/search/given_name/armanddp/family_name/du%20plessis',
        {:controller => :profiles, :action => :search, :specs => ['given_name', 'armanddp', 'family_name', 'du plessis']})
    end
#    should 'generate a search query when provided with elements' do
#      assert_routing('/profiles/search/given_name/armanddp/family_name/du plessis', {:controller => 'profiles', :action => 'search', :specs => #['given_name', 'armanddp', 'family_name', 'du%20plessis']})
#    end
  end

   context 'on GET to :search' do
     should "find a profile when logged in" do
       p = profiles(:user2)
       get :search, {:given_name => 'joe'}
       assert_not_nil assigns(:results)
       assert_response :success
       assert_template 'search'
     end
   end
end
