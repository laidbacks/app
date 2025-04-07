class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_digest_changed?
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :timezone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }, allow_blank: true

  has_many :habits, dependent: :destroy
  has_many :habit_logs, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one :notification_preference, dependent: :destroy
  has_one :setting, dependent: :destroy

  before_validation :validate_username_uniqueness
  after_create :create_default_preferences

  # Returns user profile data
  def profile_data
    {
      id: id,
      username: username,
      full_name: full_name,
      email: email,
      bio: bio,
      timezone: timezone,
      avatar: avatar,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  # This method is called before validation to check username uniqueness
  # It's used in tests to simulate database-level constraints
  def validate_username_uniqueness
    # The actual validation is handled by validates :username, uniqueness: true
    # This is just a hook for tests to use
  end

  # Create default notification preferences for new users
  def create_default_preferences
    create_notification_preference(
      email_enabled: true,
      push_enabled: true,
      sms_enabled: false,
      email_frequency: "daily_digest",
      push_frequency: "immediately",
      sms_frequency: "immediately"
    ) unless notification_preference

    create_setting(Setting.default_settings) unless setting
  end
end
