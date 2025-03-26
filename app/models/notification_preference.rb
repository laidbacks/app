class NotificationPreference < ApplicationRecord
  belongs_to :user

  enum email_frequency: {
    immediately: "immediately",
    daily_digest: "daily_digest",
    weekly_digest: "weekly_digest"
  }, _default: "immediately"

  enum push_frequency: {
    immediately: "immediately",
    batched: "batched"
  }, _default: "immediately"

  enum sms_frequency: {
    immediately: "immediately",
    daily_digest: "daily_digest"
  }, _default: "immediately"

  validates :email_enabled, inclusion: { in: [ true, false ] }
  validates :push_enabled, inclusion: { in: [ true, false ] }
  validates :sms_enabled, inclusion: { in: [ true, false ] }
  validates :email_frequency, presence: true, if: :email_enabled
  validates :push_frequency, presence: true, if: :push_enabled
  validates :sms_frequency, presence: true, if: :sms_enabled
end
