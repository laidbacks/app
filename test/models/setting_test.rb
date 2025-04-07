require "test_helper"

class SettingTest < ActiveSupport::TestCase
  setup do
    @user = users(:default)
    @setting = @user.setting || @user.create_setting(Setting.default_settings)
  end

  test "should not save setting without user" do
    setting = Setting.new(
      theme: "light",
      notifications_enabled: true,
      email_notifications_enabled: true
    )
    assert_not setting.save, "Saved the setting without a user"
  end

  test "should save setting with valid attributes" do
    setting = Setting.new(
      user: @user,
      theme: "dark",
      notifications_enabled: false,
      email_notifications_enabled: true
    )
    assert setting.save, "Could not save setting with valid attributes"
  end

  test "should validate theme inclusion" do
    setting = Setting.new(
      user: @user,
      theme: "invalid_theme",
      notifications_enabled: true,
      email_notifications_enabled: true
    )
    assert_not setting.save, "Saved setting with invalid theme"
    assert_includes setting.errors[:theme], "is not included in the list"
  end

  test "should allow nil theme" do
    setting = Setting.new(
      user: @user,
      theme: nil,
      notifications_enabled: true,
      email_notifications_enabled: true
    )
    assert setting.save, "Could not save setting with nil theme"
  end

  test "should validate notifications_enabled is boolean" do
    setting = Setting.new(
      user: @user,
      theme: "light",
      notifications_enabled: nil,
      email_notifications_enabled: true
    )
    assert_not setting.save, "Saved setting with nil notifications_enabled"
    assert_includes setting.errors[:notifications_enabled], "is not included in the list"
  end

  test "should validate email_notifications_enabled is boolean" do
    setting = Setting.new(
      user: @user,
      theme: "light",
      notifications_enabled: true,
      email_notifications_enabled: nil
    )
    assert_not setting.save, "Saved setting with nil email_notifications_enabled"
    assert_includes setting.errors[:email_notifications_enabled], "is not included in the list"
  end

  test "default_settings should return valid defaults" do
    defaults = Setting.default_settings
    assert_equal "system", defaults[:theme]
    assert_equal true, defaults[:notifications_enabled]
    assert_equal true, defaults[:email_notifications_enabled]
  end
end
