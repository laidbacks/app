require "test_helper"

class HabitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post login_path, params: { username: @user.username, password: "password" }
  end

  test "should get index" do
    get habits_path
    assert_response :success
  end

  test "should get show" do
    get habit_path(habits(:one))
    assert_response :success
  end
end
