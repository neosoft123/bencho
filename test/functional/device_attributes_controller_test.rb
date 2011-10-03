require 'test_helper'

class DeviceAttributesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:device_attributes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create device_attribute" do
    assert_difference('DeviceAttribute.count') do
      post :create, :device_attribute => { }
    end

    assert_redirected_to device_attribute_path(assigns(:device_attribute))
  end

  test "should show device_attribute" do
    get :show, :id => device_attributes(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => device_attributes(:one).id
    assert_response :success
  end

  test "should update device_attribute" do
    put :update, :id => device_attributes(:one).id, :device_attribute => { }
    assert_redirected_to device_attribute_path(assigns(:device_attribute))
  end

  test "should destroy device_attribute" do
    assert_difference('DeviceAttribute.count', -1) do
      delete :destroy, :id => device_attributes(:one).id
    end

    assert_redirected_to device_attributes_path
  end
end
