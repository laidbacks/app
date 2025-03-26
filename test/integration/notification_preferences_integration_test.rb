require "test_helper"

class NotificationPreferencesIntegrationTest < ActionDispatch::IntegrationTest
  # No need to include Devise::Test::IntegrationHelpers since it's not working correctly with our setup

  setup do
    @user = users(:default)
    # Use our custom authentication helper
    sign_in_as(@user)

    # Ensure the user has notification preferences
    @preferences = @user.notification_preference || @user.create_notification_preference(
      email_enabled: true,
      push_enabled: true,
      sms_enabled: false,
      email_frequency: "immediately",
      push_frequency: "immediately",
      sms_frequency: "immediately"
    )
  end

  test "can fetch notification preferences" do
    get api_v1_notification_preferences_path
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @preferences.email_enabled, json_response["email_enabled"]
    assert_equal @preferences.push_enabled, json_response["push_enabled"]
    assert_equal @preferences.sms_enabled, json_response["sms_enabled"]
  end

  test "can update notification preferences" do
    patch api_v1_notification_preferences_path, params: {
      preferences: {
        email_enabled: false,
        push_enabled: true,
        sms_enabled: true,
        email_frequency: "daily_digest",
        push_frequency: "immediately",
        sms_frequency: "immediately"
      }
    }

    assert_response :success

    # Reload preferences from database
    @preferences.reload

    # Assert values were updated
    assert_equal false, @preferences.email_enabled
    assert_equal true, @preferences.push_enabled
    assert_equal true, @preferences.sms_enabled
    assert_equal "daily_digest", @preferences.email_frequency
  end

  test "handles invalid preferences update" do
    # Test with invalid frequency
    patch api_v1_notification_preferences_path, params: {
      preferences: {
        email_enabled: true,
        push_enabled: true,
        sms_enabled: false,
        email_frequency: "invalid_frequency",
        push_frequency: "immediately",
        sms_frequency: "immediately"
      }
    }

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
  end
end
