class Habit < ApplicationRecord
  belongs_to :user
  has_many :habit_logs, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :frequency, presence: true

  # Define frequency options as constants for use throughout the app
  FREQUENCIES = [ "daily", "weekly", "monthly", "custom" ].freeze

  # Scopes
  scope :active, -> { where(active: true) }

  # Methods
  def completion_rate(start_date = 30.days.ago, end_date = Date.today)
    logs_in_period = habit_logs.where(date: start_date..end_date)
    total_logs = logs_in_period.count
    return 0 if total_logs.zero?

    (logs_in_period.where(completed: true).count.to_f / total_logs) * 100
  end

  # Calculate the current streak of consecutive days the habit has been completed
  def current_streak
    # Start from today and go backwards
    current_date = Date.today
    streak = 0

    # For non-daily habits, we need to adjust how we calculate streaks
    if frequency == "daily"
      # Keep counting backwards until we find a day the habit wasn't completed
      while habit_logs.find_by(date: current_date, completed: true)
        streak += 1
        current_date = current_date - 1.day
      end
    elsif frequency == "weekly"
      # Count completed weeks
      week_start = Date.today.beginning_of_week
      while habit_logs.where(date: (week_start..week_start.end_of_week), completed: true).exists?
        streak += 1
        week_start = week_start - 1.week
      end
    elsif frequency == "monthly"
      # Count completed months
      month_start = Date.today.beginning_of_month
      while habit_logs.where(date: (month_start..month_start.end_of_month), completed: true).exists?
        streak += 1
        month_start = month_start - 1.month
      end
    else # custom frequency
      # Default to daily calculation for custom frequency
      while habit_logs.find_by(date: current_date, completed: true)
        streak += 1
        current_date = current_date - 1.day
      end
    end

    streak
  end

  # Calculate the best streak (longest consecutive streak) ever achieved
  def best_streak
    return 0 if habit_logs.empty?

    # Get all completed logs ordered by date
    completed_logs = habit_logs.where(completed: true).order(date: :asc)
    return 0 if completed_logs.empty?

    # For daily habits
    if frequency == "daily"
      longest_streak = 0
      current_streak = 1

      # Start with the first log
      previous_date = completed_logs.first.date

      # Iterate through the rest of the logs
      completed_logs.offset(1).each do |log|
        if log.date == previous_date + 1.day
          # Consecutive day, increment streak
          current_streak += 1
        else
          # Streak broken, update longest_streak if current is better
          longest_streak = [ longest_streak, current_streak ].max
          current_streak = 1
        end

        previous_date = log.date
      end

      # Check one last time at the end
      longest_streak = [ longest_streak, current_streak ].max

      longest_streak
    elsif frequency == "weekly"
      # Similar logic but for weekly frequency
      longest_streak = 0
      current_streak = 1

      # Group logs by week
      logs_by_week = {}

      completed_logs.each do |log|
        week_start = log.date.beginning_of_week
        logs_by_week[week_start] = true
      end

      # Sort weeks
      weeks = logs_by_week.keys.sort
      return 0 if weeks.empty?

      previous_week = weeks.first

      weeks.drop(1).each do |week|
        if week == previous_week + 1.week
          current_streak += 1
        else
          longest_streak = [ longest_streak, current_streak ].max
          current_streak = 1
        end

        previous_week = week
      end

      longest_streak = [ longest_streak, current_streak ].max

      longest_streak
    elsif frequency == "monthly"
      # Similar logic but for monthly frequency
      longest_streak = 0
      current_streak = 1

      # Group logs by month
      logs_by_month = {}

      completed_logs.each do |log|
        month_start = log.date.beginning_of_month
        logs_by_month[month_start] = true
      end

      # Sort months
      months = logs_by_month.keys.sort
      return 0 if months.empty?

      previous_month = months.first

      months.drop(1).each do |month|
        if month == previous_month + 1.month
          current_streak += 1
        else
          longest_streak = [ longest_streak, current_streak ].max
          current_streak = 1
        end

        previous_month = month
      end

      longest_streak = [ longest_streak, current_streak ].max

      longest_streak
    else
      # For custom frequency, use the daily calculation
      best_streak_daily(completed_logs)
    end
  end

  private

  # Helper method for calculating daily best streak
  def best_streak_daily(completed_logs)
    longest_streak = 0
    current_streak = 1

    # Start with the first log
    return 0 if completed_logs.empty?
    previous_date = completed_logs.first.date

    # Iterate through the rest of the logs
    completed_logs.offset(1).each do |log|
      if log.date == previous_date + 1.day
        # Consecutive day, increment streak
        current_streak += 1
      else
        # Streak broken, update longest_streak if current is better
        longest_streak = [ longest_streak, current_streak ].max
        current_streak = 1
      end

      previous_date = log.date
    end

    # Check one last time at the end
    [ longest_streak, current_streak ].max
  end
end
