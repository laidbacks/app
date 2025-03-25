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
end
