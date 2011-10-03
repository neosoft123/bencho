require 'test_helper'

class AccountentriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:accountentries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create accountentry" do
    assert_difference('Accountentry.count') do
      post :create, :accountentry => { }
    end

    assert_redirected_to accountentry_path(assigns(:accountentry))
  end

  test "should show accountentry" do
    get :show, :id => accountentries(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => accountentries(:one).id
    assert_response :success
  end

  test "should update accountentry" do
    put :update, :id => accountentries(:one).id, :accountentry => { }
    assert_redirected_to accountentry_path(assigns(:accountentry))
  end

  test "should destroy accountentry" do
    assert_difference('Accountentry.count', -1) do
      delete :destroy, :id => accountentries(:one).id
    end

    assert_redirected_to accountentries_path
  end
end
