require 'test_helper'

class TextMessagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:text_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create text_message" do
    assert_difference('TextMessage.count') do
      post :create, :text_message => { }
    end

    assert_redirected_to text_message_path(assigns(:text_message))
  end

  test "should show text_message" do
    get :show, :id => text_messages(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => text_messages(:one).id
    assert_response :success
  end

  test "should update text_message" do
    put :update, :id => text_messages(:one).id, :text_message => { }
    assert_redirected_to text_message_path(assigns(:text_message))
  end

  test "should destroy text_message" do
    assert_difference('TextMessage.count', -1) do
      delete :destroy, :id => text_messages(:one).id
    end

    assert_redirected_to text_messages_path
  end
end
