class NotificationPreference < ApplicationRecord
  belongs_to :user

  # Simple string validation instead of using enum
  validates :email_frequency, inclusion: { in: %w[immediately daily_digest weekly_digest] }
  validates :push_frequency, inclusion: { in: %w[immediately batched] }
  validates :sms_frequency, inclusion: { in: %w[immediately daily_digest] }

  validates :email_enabled, inclusion: { in: [ true, false ] }
  validates :push_enabled, inclusion: { in: [ true, false ] }
  validates :sms_enabled, inclusion: { in: [ true, false ] }
  validates :email_frequency, presence: true, if: :email_enabled
  validates :push_frequency, presence: true, if: :push_enabled
  validates :sms_frequency, presence: true, if: :sms_enabled
end
