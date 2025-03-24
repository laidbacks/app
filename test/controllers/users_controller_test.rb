require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get users_new_url
    assert_response :success
  end

  test "should get create" do
    post signup_path, params: { 
      user: { 
        username: "testuser123", 
        password: "password123",
        password_confirmation: "password123"
      } 
    }
    assert_response :redirect
    assert_redirected_to profile_path
  end
end
