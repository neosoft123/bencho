require 'test_helper'

class AccountEntriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:account_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create account_entry" do
    assert_difference('AccountEntry.count') do
      post :create, :account_entry => { }
    end

    assert_redirected_to account_entry_path(assigns(:account_entry))
  end

  test "should show account_entry" do
    get :show, :id => account_entries(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => account_entries(:one).id
    assert_response :success
  end

  test "should update account_entry" do
    put :update, :id => account_entries(:one).id, :account_entry => { }
    assert_redirected_to account_entry_path(assigns(:account_entry))
  end

  test "should destroy account_entry" do
    assert_difference('AccountEntry.count', -1) do
      delete :destroy, :id => account_entries(:one).id
    end

    assert_redirected_to account_entries_path
  end
end
