require "test_helper"

class SettingsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default)
    sign_in_as(@user)
  end

  test "should get settings page" do
    get settings_path
    assert_response :success
    assert_select "h4", "Settings"
    assert_select "div.settings-section", count: 2
  end

  test "should show theme preferences" do
    get settings_path
    assert_response :success
    assert_select "h5", "Theme Preferences"
    assert_select "select[name='setting[theme]']"
    assert_select "option[value='light']"
    assert_select "option[value='dark']"
    assert_select "option[value='system']"
  end

  test "should show notification settings" do
    get settings_path
    assert_response :success
    assert_select "h5", "Notification Settings"
    assert_select "input[name='setting[notifications_enabled]']"
    assert_select "input[name='setting[email_notifications_enabled]']"
  end

  test "should show advanced notification options" do
    get settings_path
    assert_response :success
    assert_select "div[data-settings-target='advancedNotificationOptions']"
    assert_select "h6", "Advanced Notification Preferences"
    assert_select "select[id='email_frequency']"
    assert_select "select[id='push_frequency']"
    assert_select "select[id='sms_frequency']"
  end

  test "should update settings successfully" do
    patch settings_path, params: {
      setting: {
        theme: "dark",
        notifications_enabled: "1",
        email_notifications_enabled: "0"
      }
    }
    assert_redirected_to settings_path
    assert_equal "Settings updated successfully.", flash[:notice]

    # Reload the setting from the database
    @user.setting.reload
    assert_equal "dark", @user.setting.theme
    assert_equal true, @user.setting.notifications_enabled
    assert_equal false, @user.setting.email_notifications_enabled
  end

  test "should handle invalid settings" do
    # Force validation error by sending invalid theme
    patch settings_path, params: {
      setting: {
        theme: "invalid_theme",
        notifications_enabled: "1",
        email_notifications_enabled: "1"
      }
    }
    assert_response :unprocessable_entity

    # Confirm the setting was not updated
    @user.setting.reload
    assert_not_equal "invalid_theme", @user.setting.theme
  end

  test "should redirect to login when not authenticated" do
    sign_out
    get settings_path
    assert_redirected_to login_path
    assert_equal "You must be logged in to access this page", flash[:alert]
  end

  test "should be accessible from sidebar" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", settings_path
    assert_select "span.new-badge", "New" # Check if the new badge is shown
  end

  private

  def sign_out
    delete logout_path
  end
end
