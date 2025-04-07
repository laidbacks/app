require "test_helper"

class HabitTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @habit = Habit.create(
      name: "Test Habit",
      description: "Test Description",
      frequency: "daily",
      active: true,
      user: @user
    )
  end

  test "should be valid with valid attributes" do
    assert @habit.valid?
  end

  test "should not be valid without a name" do
    @habit.name = nil
    assert_not @habit.valid?
    assert_includes @habit.errors[:name], "can't be blank"
  end

  test "should not be valid without a frequency" do
    @habit.frequency = nil
    assert_not @habit.valid?
    assert_includes @habit.errors[:frequency], "can't be blank"
  end

  test "should not be valid without a user" do
    @habit.user = nil
    assert_not @habit.valid?
    assert_includes @habit.errors[:user], "must exist"
  end

  test "should calculate completion rate correctly" do
    # Create 10 logs, 7 completed and 3 uncompleted
    (0..9).each do |days_ago|
      @habit.habit_logs.create(
        date: days_ago.days.ago.to_date,
        completed: days_ago < 7, # Last 7 days are completed
        user: @user
      )
    end

    # The completion rate should be 70% (7 out of 10)
    assert_in_delta 70.0, @habit.completion_rate, 0.1

    # For debugging purposes
    seven_days_ago = 7.days.ago.to_date
    logs_in_seven_days = @habit.habit_logs.where(date: seven_days_ago..Date.today)
    completed_logs = logs_in_seven_days.where(completed: true)

    puts "Seven days ago: #{seven_days_ago}"
    puts "Total logs in 7 days: #{logs_in_seven_days.count}"
    puts "Completed logs in 7 days: #{completed_logs.count}"
    puts "Completion rate: #{(completed_logs.count.to_f / logs_in_seven_days.count) * 100}%"

    # Last 7 days includes 8 logs with 7 completed (87.5%)
    assert_in_delta 87.5, @habit.completion_rate(7.days.ago.beginning_of_day), 0.1
    assert_in_delta 70.0, @habit.completion_rate(30.days.ago), 0.1 # Last 30 days (or 10 in our test) should be 70%
  end

  test "should calculate current streak for daily habit" do
    # Create a streak of 5 days, then 2 days broken
    # Day 0 (today): completed
    # Day 1 (yesterday): completed
    # Day 2: completed
    # Day 3: completed
    # Day 4: completed
    # Day 5: not completed
    # Day 6: not completed

    (0..6).each do |days_ago|
      @habit.habit_logs.create(
        date: days_ago.days.ago.to_date,
        completed: days_ago < 5, # Last 5 days are completed
        user: @user
      )
    end

    assert_equal 5, @habit.current_streak
  end

  test "should calculate best streak for daily habit" do
    # Create logs with multiple streaks:
    # Streak 1: 3 days
    # Break
    # Streak 2: 5 days
    # Break
    # Streak 3: 2 days (current)

    # Days ago: 0-1 (streak 3)
    [ 0, 1 ].each do |days_ago|
      @habit.habit_logs.create(
        date: days_ago.days.ago.to_date,
        completed: true,
        user: @user
      )
    end

    # Day 2: break
    @habit.habit_logs.create(
      date: 2.days.ago.to_date,
      completed: false,
      user: @user
    )

    # Days ago: 3-7 (streak 2)
    (3..7).each do |days_ago|
      @habit.habit_logs.create(
        date: days_ago.days.ago.to_date,
        completed: true,
        user: @user
      )
    end

    # Day 8: break
    @habit.habit_logs.create(
      date: 8.days.ago.to_date,
      completed: false,
      user: @user
    )

    # Days ago: 9-11 (streak 1)
    (9..11).each do |days_ago|
      @habit.habit_logs.create(
        date: days_ago.days.ago.to_date,
        completed: true,
        user: @user
      )
    end

    assert_equal 2, @habit.current_streak # Current streak is 2 days
    assert_equal 5, @habit.best_streak # Best streak is 5 days (days 3-7)
  end

  test "should calculate streaks for weekly habit" do
    @weekly_habit = Habit.create(
      name: "Weekly Habit",
      description: "Test weekly habit",
      frequency: "weekly",
      active: true,
      user: @user
    )

    # Create 5 weeks of logs, with weeks 0-2 completed and weeks 3-4 not completed
    (0..4).each do |weeks_ago|
      date = (weeks_ago * 7).days.ago.to_date
      @weekly_habit.habit_logs.create(
        date: date,
        completed: weeks_ago < 3, # Last 3 weeks completed
        user: @user
      )
    end

    assert_equal 3, @weekly_habit.current_streak # Current streak is 3 weeks
  end

  test "should calculate streaks for monthly habit" do
    @monthly_habit = Habit.create(
      name: "Monthly Habit",
      description: "Test monthly habit",
      frequency: "monthly",
      active: true,
      user: @user
    )

    # Create 4 months of logs, with months 0-1 completed and months 2-3 not completed
    (0..3).each do |months_ago|
      date = Date.today.beginning_of_month - months_ago.months
      @monthly_habit.habit_logs.create(
        date: date,
        completed: months_ago < 2, # Last 2 months completed
        user: @user
      )
    end

    assert_equal 2, @monthly_habit.current_streak # Current streak is 2 months
  end

  test "should scope active habits correctly" do
    @habit.active = true
    @habit.save

    inactive_habit = Habit.create(
      name: "Inactive Habit",
      frequency: "daily",
      user: @user,
      active: false
    )

    active_habits = Habit.active

    assert_includes active_habits, @habit
    assert_not_includes active_habits, inactive_habit
  end
end
