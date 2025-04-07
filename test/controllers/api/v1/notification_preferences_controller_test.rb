require "test_helper"

class Api::V1::NotificationPreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default)
    @user.create_notification_preference(
      email_enabled: true,
      push_enabled: true,
      sms_enabled: false,
      email_frequency: "immediately",
      push_frequency: "immediately",
      sms_frequency: "immediately"
    ) unless @user.notification_preference

    # Use the authentication helper to sign in
    sign_in_as(@user)
  end

  test "should get notification preferences" do
    get api_v1_notification_preferences_path
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal true, json_response["email_enabled"]
    assert_equal true, json_response["push_enabled"]
    assert_equal false, json_response["sms_enabled"]
    assert_equal "immediately", json_response["email_frequency"]
  end

  test "should update notification preferences" do
    patch api_v1_notification_preferences_path, params: {
      preferences: {
        email_enabled: false,
        push_enabled: true,
        sms_enabled: true,
        email_frequency: "daily_digest",
        push_frequency: "immediately",
        sms_frequency: "immediately"
      }
    }, as: :json

    assert_response :success

    # Reload from database
    @user.notification_preference.reload

    # Check values were updated
    assert_equal false, @user.notification_preference.email_enabled
    assert_equal true, @user.notification_preference.push_enabled
    assert_equal true, @user.notification_preference.sms_enabled
    assert_equal "daily_digest", @user.notification_preference.email_frequency
  end

  test "should handle invalid preferences" do
    patch api_v1_notification_preferences_path, params: {
      preferences: {
        email_enabled: true,
        push_enabled: true,
        sms_enabled: true,
        email_frequency: "invalid_frequency", # Invalid value
        push_frequency: "immediately",
        sms_frequency: "immediately"
      }
    }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
  end

  test "should require authentication" do
    sign_out # Log out

    get api_v1_notification_preferences_path
    assert_response :unauthorized

    patch api_v1_notification_preferences_path, params: {
      preferences: {
        email_enabled: false,
        push_enabled: true
      }
    }, as: :json
    assert_response :unauthorized
  end
end
