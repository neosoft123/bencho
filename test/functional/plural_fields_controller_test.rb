require 'test_helper'

class PluralFieldsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plural_fields)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plural_fields" do
    assert_difference('PluralFields.count') do
      post :create, :plural_fields => { }
    end

    assert_redirected_to plural_fields_path(assigns(:plural_fields))
  end

  test "should show plural_fields" do
    get :show, :id => plural_fields(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => plural_fields(:one).id
    assert_response :success
  end

  test "should update plural_fields" do
    put :update, :id => plural_fields(:one).id, :plural_fields => { }
    assert_redirected_to plural_fields_path(assigns(:plural_fields))
  end

  test "should destroy plural_fields" do
    assert_difference('PluralFields.count', -1) do
      delete :destroy, :id => plural_fields(:one).id
    end

    assert_redirected_to plural_fields_path
  end
end
