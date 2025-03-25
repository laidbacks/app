require "test_helper"

module Api
  class HabitLogsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:one)
      @password = "password123"
      @habit = Habit.create(
        name: "Test Habit",
        description: "Test Description",
        frequency: "daily",
        user: @user
      )

      @habit_log = HabitLog.create(
        date: Date.today,
        notes: "Test note",
        completed: true,
        habit: @habit,
        user: @user
      )

      # Simulate login
      sign_in_as(@user, @password)
    end

    test "should get index" do
      get api_habit_logs_url, as: :json
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_includes json_response.map { |log| log["id"] }, @habit_log.id
    end

    test "should get habit-specific logs" do
      get api_habit_habit_logs_url(@habit), as: :json
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_includes json_response.map { |log| log["id"] }, @habit_log.id
    end

    test "should get logs by date range" do
      get api_habit_logs_url, params: {
        start_date: Date.yesterday.to_s,
        end_date: Date.tomorrow.to_s
      }, as: :json

      assert_response :success

      json_response = JSON.parse(response.body)
      assert_includes json_response.map { |log| log["id"] }, @habit_log.id
    end

    test "should filter by completion status" do
      incomplete_log = HabitLog.create(
        date: Date.yesterday,
        notes: "Incomplete log",
        completed: false,
        habit: @habit,
        user: @user
      )

      # Get completed logs
      get api_habit_logs_url, params: { completed: true }, as: :json
      assert_response :success

      json_response = JSON.parse(response.body)
      log_ids = json_response.map { |log| log["id"] }

      assert_includes log_ids, @habit_log.id
      assert_not_includes log_ids, incomplete_log.id
    end

    test "should show habit log" do
      get api_habit_log_url(@habit_log), as: :json
      assert_response :success

      json_response = JSON.parse(response.body)
      assert_equal @habit_log.id, json_response["id"]
    end

    test "should create habit log" do
      assert_difference("HabitLog.count") do
        post api_habit_habit_logs_url(@habit), params: {
          habit_log: {
            date: Date.tomorrow.to_s,
            notes: "New habit log",
            completed: true
          }
        }, as: :json
      end

      assert_response :created
    end

    test "should not create invalid habit log" do
      assert_no_difference("HabitLog.count") do
        post api_habit_habit_logs_url(@habit), params: {
          habit_log: {
            date: nil,
            notes: "Invalid log",
            completed: true
          }
        }, as: :json
      end

      assert_response :unprocessable_entity
    end

    test "should update habit log" do
      patch api_habit_log_url(@habit_log), params: {
        habit_log: {
          notes: "Updated notes"
        }
      }, as: :json

      assert_response :success

      @habit_log.reload
      assert_equal "Updated notes", @habit_log.notes
    end

    test "should destroy habit log" do
      assert_difference("HabitLog.count", -1) do
        delete api_habit_log_url(@habit_log), as: :json
      end

      assert_response :no_content
    end

    test "should toggle today's log" do
      # Delete existing log for today to have a clean state
      @habit.habit_logs.where(date: Date.today).destroy_all

      # Should create a new log (completed: true) if none exists
      patch "/api/habits/#{@habit.id}/toggle_today", as: :json
      assert_response :success

      log = @habit.habit_logs.find_by(date: Date.today, user: @user)
      assert log.present?
      assert log.completed?

      # Should toggle existing log to false
      patch "/api/habits/#{@habit.id}/toggle_today", as: :json
      assert_response :success

      log.reload
      assert_not log.completed?
    end
  end
end
