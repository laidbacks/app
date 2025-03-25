require "test_helper"

class HabitTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @habit = Habit.new(
      name: "Daily Meditation",
      description: "Meditate for 10 minutes every day",
      frequency: "daily",
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
    @habit.save

    # Create some habit logs (50% completion rate)
    @habit.habit_logs.create(date: 1.day.ago, completed: true, user: @user)
    @habit.habit_logs.create(date: 2.days.ago, completed: false, user: @user)

    assert_equal 50.0, @habit.completion_rate(3.days.ago, Date.today)
  end

  test "should return 0 completion rate when no logs exist" do
    @habit.save
    assert_equal 0, @habit.completion_rate(3.days.ago, Date.today)
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
