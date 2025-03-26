require "test_helper"

class NotificationApiIntegrationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:default)
    sign_in @user

    # Create a test notification
    @notification = @user.notifications.create!(
      title: "Test Notification",
      body: "This is a test notification.",
      notification_type: "email",
      status: "pending"
    )
  end

  test "can fetch notifications" do
    get api_v1_notifications_path
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_includes json_response.map { |n| n["id"] }, @notification.id
  end

  test "can create notification" do
    assert_difference -> { @user.notifications.count } do
      post api_v1_notifications_path, params: {
        notification: {
          title: "New Notification",
          body: "This is a new test notification.",
          notification_type: "push"
        }
      }

      assert_response :created
    end

    json_response = JSON.parse(response.body)
    assert_equal "New Notification", json_response["title"]
    assert_equal "push", json_response["notification_type"]
  end

  test "can update notification" do
    patch api_v1_notification_path(@notification), params: {
      notification: {
        title: "Updated Title",
        body: "Updated body"
      }
    }

    assert_response :success

    # Reload notification from database
    @notification.reload

    # Assert values were updated
    assert_equal "Updated Title", @notification.title
    assert_equal "Updated body", @notification.body
  end

  test "can schedule notification" do
    post schedule_api_v1_notification_path(@notification), params: {
      schedule: {
        schedule_type: "one_time",
        frequency: "daily",
        scheduled_at: 1.day.from_now
      }
    }

    assert_response :success

    # Reload notification from database
    @notification.reload

    # Assert notification was scheduled
    assert_equal "scheduled", @notification.status
    assert @notification.notification_schedule.present?
    assert_equal "one_time", @notification.notification_schedule.schedule_type
  end

  test "can cancel scheduled notification" do
    # First schedule the notification
    @notification.schedule(
      schedule_type: "one_time",
      frequency: "daily",
      scheduled_at: 1.day.from_now
    )

    # Then cancel it
    patch cancel_api_v1_notification_path(@notification)
    assert_response :success

    # Reload notification from database
    @notification.reload

    # Assert notification was cancelled
    assert_equal "pending", @notification.status
    assert_nil @notification.notification_schedule
  end
end
