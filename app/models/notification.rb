class Notification < ApplicationRecord
  belongs_to :user
  has_one :notification_schedule, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :notification_type, presence: true
  validates :status, presence: true

  enum :notification_type, {
    email: "email",
    push: "push",
    sms: "sms"
  }

  enum :status, {
    pending: "pending",
    scheduled: "scheduled",
    sent: "sent",
    failed: "failed"
  }

  scope :scheduled, -> { where(status: "scheduled") }
  scope :pending, -> { where(status: "pending") }
  scope :sent, -> { where(status: "sent") }
  scope :failed, -> { where(status: "failed") }

  def schedule(schedule_type:, frequency:, scheduled_at:)
    build_notification_schedule(
      schedule_type: schedule_type,
      frequency: frequency,
      scheduled_at: scheduled_at
    )
    self.status = "scheduled"
    save
  end

  def mark_as_sent!
    update(status: "sent")
    notification_schedule&.update(last_sent_at: Time.current)
  end

  def mark_as_failed!
    update(status: "failed")
  end
end
