require "test_helper"

class HabitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user, "password123")
    @habit = habits(:one)
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
