require 'test_helper'

class KontactInformationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:kontact_informations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create kontact_information" do
    assert_difference('KontactInformation.count') do
      post :create, :kontact_information => { }
    end

    assert_redirected_to kontact_information_path(assigns(:kontact_information))
  end

  test "should show kontact_information" do
    get :show, :id => kontact_informations(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => kontact_informations(:one).id
    assert_response :success
  end

  test "should update kontact_information" do
    put :update, :id => kontact_informations(:one).id, :kontact_information => { }
    assert_redirected_to kontact_information_path(assigns(:kontact_information))
  end

  test "should destroy kontact_information" do
    assert_difference('KontactInformation.count', -1) do
      delete :destroy, :id => kontact_informations(:one).id
    end

    assert_redirected_to kontact_informations_path
  end
end
