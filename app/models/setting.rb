class Setting < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :theme, inclusion: { in: %w[light dark system] }, allow_nil: true
  validates :notifications_enabled, inclusion: { in: [ true, false ] }
  validates :email_notifications_enabled, inclusion: { in: [ true, false ] }

  def self.default_settings
    {
      theme: "system",
      notifications_enabled: true,
      email_notifications_enabled: true
    }
  end
end
