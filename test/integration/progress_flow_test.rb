require "test_helper"

class ProgressFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "can navigate to progress page from sidebar" do
    # Start at the root path
    get root_path
    assert_response :success

    # Ensure the sidebar has a link to the progress page
    assert_select ".sidebar .nav-links a[href=?]", progress_path

    # Navigate to the progress page
    get progress_path
    assert_response :success

    # Check that the page has loaded
    assert_select "h1.page-title", "Progress Dashboard"
  end

  test "progress link in sidebar is marked active when on progress page" do
    # Navigate to the progress page
    get progress_path
    assert_response :success

    # Verify that the progress nav item has the 'active' class
    assert_select ".sidebar .nav-item.active a[href=?]", progress_path
  end

  test "progress charts are displayed when there are habits" do
    # Create a habit for this test
    habit = Habit.create(
      name: "Test Habit",
      description: "Test Description",
      frequency: "daily",
      active: true,
      user: @user
    )

    # Create some habit logs
    5.times do |i|
      habit.habit_logs.create(
        date: i.days.ago.to_date,
        completed: true,
        user: @user
      )
    end

    # Navigate to the progress page
    get progress_path
    assert_response :success

    # Check for chart elements
    assert_select ".chart-card", minimum: 2
    assert_select "#completionRatesChart"
    assert_select "#streakComparisonChart"
  end
end
