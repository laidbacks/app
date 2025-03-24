require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      username: "testuser",
      password: "password123",
    )
  end

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

  test "should get signup page" do
    get signup_path
    assert_response :success
    assert_select "h1", "Create Your Account"
  end

  test "should create new user" do
    assert_difference("User.count") do
      post signup_path, params: {
        user: {
          username: "newuser",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to profile_path
    assert session[:user_id].present?
    assert_equal "Account created successfully!", flash[:notice]
  end

  test "should not create user with invalid data" do
    assert_no_difference("User.count") do
      post signup_path, params: {
        user: {
          username: "",
          password: "short",
          password_confirmation: "different"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select "div.error-messages"
  end

  test "should show user profile when logged in" do
    post login_path, params: { username: @user.username, password: "password123" }

    get profile_path
    assert_response :success
    assert_select "h1", /Welcome, #{@user.username}!/
  end

  test "should redirect from profile when not logged in" do
    delete logout_path

    get profile_path
    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page", flash[:alert]
  end
end
