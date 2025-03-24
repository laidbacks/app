class NotificationSchedule < ApplicationRecord
  belongs_to :notification

  validates :schedule_type, presence: true
  validates :frequency, presence: true
  validates :scheduled_at, presence: true

  enum schedule_type: {
    one_time: "one_time",
    recurring: "recurring"
  }

  enum frequency: {
    daily: "daily",
    weekly: "weekly",
    monthly: "monthly",
    yearly: "yearly"
  }

  scope :due, -> { where("scheduled_at <= ?", Time.current) }
  scope :recurring, -> { where(schedule_type: "recurring") }
  scope :one_time, -> { where(schedule_type: "one_time") }

  def next_scheduled_time
    return nil unless recurring?

    case frequency
    when "daily"
      scheduled_at + 1.day
    when "weekly"
      scheduled_at + 1.week
    when "monthly"
      scheduled_at + 1.month
    when "yearly"
      scheduled_at + 1.year
    end
  end

  def reschedule!
    return unless recurring?

    update(scheduled_at: next_scheduled_time)
  end
end
