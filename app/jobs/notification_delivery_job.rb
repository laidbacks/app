class NotificationDeliveryJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find(notification_id)

    case notification.notification_type
    when "email"
      deliver_email(notification)
    when "push"
      deliver_push(notification)
    when "sms"
      deliver_sms(notification)
    end

    notification.mark_as_sent!
    notification.notification_schedule&.reschedule!
  rescue StandardError => e
    Rails.logger.error("Failed to deliver notification #{notification_id}: #{e.message}")
    notification.mark_as_failed!
  end

  private

  def deliver_email(notification)
    # Implement email delivery logic here
    # Example: UserMailer.notification(notification.user, notification).deliver_now
  end

  def deliver_push(notification)
    # Implement push notification delivery logic here
    # Example: PushNotificationService.deliver(notification.user, notification)
  end

  def deliver_sms(notification)
    # Implement SMS delivery logic here
    # Example: SMSService.deliver(notification.user.phone_number, notification.body)
  end
end
