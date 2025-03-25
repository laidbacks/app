require "test_helper"

class HabitLogTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @habit = Habit.create(
      name: "Daily Exercise",
      description: "Exercise for 30 minutes",
      frequency: "daily",
      user: @user
    )
    @habit_log = HabitLog.new(
      date: Date.today,
      completed: true,
      notes: "Completed successfully",
      habit: @habit,
      user: @user
    )
  end

  test "should be valid with valid attributes" do
    assert @habit_log.valid?
  end

  test "should not be valid without a date" do
    @habit_log.date = nil
    assert_not @habit_log.valid?
    assert_includes @habit_log.errors[:date], "can't be blank"
  end

  test "should not be valid without a completed status" do
    @habit_log.completed = nil
    assert_not @habit_log.valid?
    assert_includes @habit_log.errors[:completed], "is not included in the list"
  end

  test "should not be valid without a habit" do
    @habit_log.habit = nil
    assert_not @habit_log.valid?
    assert_includes @habit_log.errors[:habit], "must exist"
  end

  test "should not be valid without a user" do
    @habit_log.user = nil
    assert_not @habit_log.valid?
    assert_includes @habit_log.errors[:user], "must exist"
  end

  test "should not be valid if user doesn't match habit's user" do
    other_user = User.create(username: "otheruser", password: "password123")
    @habit_log.user = other_user
    assert_not @habit_log.valid?
    assert_includes @habit_log.errors[:user], "must match the habit's user"
  end

  test "should scope completed logs correctly" do
    @habit_log.save

    incomplete_log = HabitLog.create(
      date: Date.yesterday,
      completed: false,
      habit: @habit,
      user: @user
    )

    completed_logs = HabitLog.completed

    assert_includes completed_logs, @habit_log
    assert_not_includes completed_logs, incomplete_log
  end

  test "should scope incomplete logs correctly" do
    @habit_log.save

    incomplete_log = HabitLog.create(
      date: Date.yesterday,
      completed: false,
      habit: @habit,
      user: @user
    )

    incomplete_logs = HabitLog.incomplete

    assert_not_includes incomplete_logs, @habit_log
    assert_includes incomplete_logs, incomplete_log
  end

  test "should scope logs by date range correctly" do
    @habit_log.save

    old_log = HabitLog.create(
      date: 10.days.ago,
      completed: true,
      habit: @habit,
      user: @user
    )

    recent_logs = HabitLog.for_date_range(5.days.ago, Date.today)

    assert_includes recent_logs, @habit_log
    assert_not_includes recent_logs, old_log
  end

  test "should order logs by most recent date" do
    # Clear existing logs to avoid interference from fixtures
    @habit.habit_logs.destroy_all

    older_log = HabitLog.create(
      date: 1.day.ago,
      completed: true,
      habit: @habit,
      user: @user
    )

    today_log = HabitLog.create(
      date: Date.today,
      completed: true,
      habit: @habit,
      user: @user
    )

    # Only find logs for our specific habit to avoid interference from fixtures
    ordered_logs = @habit.habit_logs.recent.to_a

    assert_equal today_log, ordered_logs.first
    assert_equal older_log, ordered_logs.second
  end
end
