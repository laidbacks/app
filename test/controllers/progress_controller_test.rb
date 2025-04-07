require "test_helper"

class ProgressControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @password = "password123"

    # Create test habits with different statistics
    @habit1 = Habit.create(
      name: "Daily Exercise",
      description: "Exercise every day",
      frequency: "daily",
      active: true,
      user: @user
    )

    @habit2 = Habit.create(
      name: "Weekly Reading",
      description: "Read a book chapter per week",
      frequency: "weekly",
      active: true,
      user: @user
    )

    # Create an inactive habit that shouldn't show up in progress
    @inactive_habit = Habit.create(
      name: "Inactive Habit",
      description: "This habit is inactive",
      frequency: "daily",
      active: false,
      user: @user
    )

    # Create habit logs for testing
    # Daily habit logs for the last 10 days (7 completed, 3 not completed)
    (0..9).each do |days_ago|
      @habit1.habit_logs.create(
        date: days_ago.days.ago.to_date,
        completed: days_ago < 7, # Last 7 days are completed
        user: @user
      )
    end

    # Weekly habit logs for the last 5 weeks (3 completed, 2 not completed)
    (0..4).each do |weeks_ago|
      @habit2.habit_logs.create(
        date: (weeks_ago * 7).days.ago.to_date,
        completed: weeks_ago < 3, # Last 3 weeks are completed
        user: @user
      )
    end

    # Sign in as the user
    sign_in_as(@user, @password)
  end

  test "should get index page" do
    get progress_path
    assert_response :success

    # Check that the page title is in the response
    assert_select "h1.page-title", "Progress Dashboard"

    # Check that we can see at least our test habits in the table
    assert_select ".progress-table tbody tr", minimum: 2

    # Check that we have the overview cards
    assert_select ".overview-cards .card", 3
  end

  test "should show correct data in overview cards" do
    get progress_path
    assert_response :success

    # We should have total habits card
    assert_select ".overview-card", text: /Total Active Habits/

    # We should have average completion rate card
    assert_select ".overview-card", text: /Average Completion Rate/

    # We should have total streaks card
    assert_select ".overview-card", text: /Total Current Streaks/
  end

  test "should show habit details in the progress table" do
    get progress_path
    assert_response :success

    # Check that we can see our habit names
    assert_select ".progress-table", text: /Daily Exercise/
    assert_select ".progress-table", text: /Weekly Reading/

    # Check that the inactive habit is not shown
    assert_select ".progress-table", text: /Inactive Habit/, count: 0
  end

  test "should redirect to login when not authenticated" do
    # Sign out first
    sign_out

    get progress_path

    # Should redirect to login page
    assert_redirected_to login_path

    # Verify the flash message
    assert_equal "You need to sign in before accessing this page", flash[:alert]
  end

  test "should show empty state when no habits" do
    # Delete all habits for this test (including ones from fixtures)
    Habit.where(user_id: @user.id).destroy_all

    get progress_path
    assert_response :success

    # Check that we see the empty state message
    assert_select ".empty-state", text: /No active habits found/
    assert_select "a[href=?]", new_habit_path
  end
end
