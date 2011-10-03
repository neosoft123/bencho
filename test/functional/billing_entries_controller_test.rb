require 'test_helper'

class BillingEntriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:billing_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create billing_entry" do
    assert_difference('BillingEntry.count') do
      post :create, :billing_entry => { }
    end

    assert_redirected_to billing_entry_path(assigns(:billing_entry))
  end

  test "should show billing_entry" do
    get :show, :id => billing_entries(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => billing_entries(:one).id
    assert_response :success
  end

  test "should update billing_entry" do
    put :update, :id => billing_entries(:one).id, :billing_entry => { }
    assert_redirected_to billing_entry_path(assigns(:billing_entry))
  end

  test "should destroy billing_entry" do
    assert_difference('BillingEntry.count', -1) do
      delete :destroy, :id => billing_entries(:one).id
    end

    assert_redirected_to billing_entries_path
  end
end
