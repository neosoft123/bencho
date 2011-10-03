require 'test_helper'

class WalletsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wallets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create wallet" do
    assert_difference('Wallet.count') do
      post :create, :wallet => { }
    end

    assert_redirected_to wallet_path(assigns(:wallet))
  end

  test "should show wallet" do
    get :show, :id => wallets(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => wallets(:one).id
    assert_response :success
  end

  test "should update wallet" do
    put :update, :id => wallets(:one).id, :wallet => { }
    assert_redirected_to wallet_path(assigns(:wallet))
  end

  test "should destroy wallet" do
    assert_difference('Wallet.count', -1) do
      delete :destroy, :id => wallets(:one).id
    end

    assert_redirected_to wallets_path
  end
end
