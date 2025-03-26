require "test_helper"

module Api
  class HabitsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:one)
      @password = "password123"
      @habit = Habit.create(
        name: "Test Habit",
        description: "Test Description",
        frequency: "daily",
        user: @user
      )

      # Simulate login
      sign_in_as(@user, @password)
    end

    test "should get index" do
      get api_habits_url, as: :json
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_includes json_response.map { |habit| habit["name"] }, @habit.name
    end

    test "should show habit" do
      get api_habit_url(@habit), as: :json
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal @habit.name, json_response["name"]
    end

    test "should create habit" do
      assert_difference("Habit.count") do
        post api_habits_url, params: {
          habit: {
            name: "New Habit",
            description: "New habit description",
            frequency: "weekly"
          }
        }, as: :json
      end

      assert_response :created

      json_response = JSON.parse(response.body)
      assert_equal "New Habit", json_response["name"]
    end

    test "should not create invalid habit" do
      assert_no_difference("Habit.count") do
        post api_habits_url, params: {
          habit: {
            name: "",
            description: "Invalid habit",
            frequency: ""
          }
        }, as: :json
      end

      assert_response :unprocessable_entity
    end

    test "should update habit" do
      patch api_habit_url(@habit), params: {
        habit: {
          name: "Updated Habit Name"
        }
      }, as: :json

      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal "Updated Habit Name", json_response["name"]
    end

    test "should not update with invalid data" do
      patch api_habit_url(@habit), params: {
        habit: {
          name: ""
        }
      }, as: :json

      assert_response :unprocessable_entity
    end

    test "should destroy habit" do
      assert_difference("Habit.count", -1) do
        delete api_habit_url(@habit), as: :json
      end

      assert_response :no_content
    end

    test "should get habit stats" do
      # Create some logs for the habit
      @habit.habit_logs.create(date: Date.today, completed: true, user: @user)
      @habit.habit_logs.create(date: 1.day.ago, completed: false, user: @user)

      get stats_api_habit_url(@habit), as: :json
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal @habit.id, json_response["habit_id"]
      assert_equal 50.0, json_response["completion_rate"]
    end
  end
end
