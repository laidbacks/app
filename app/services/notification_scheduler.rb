class NotificationScheduler
  def self.schedule_notification(notification:, schedule_type:, frequency:, scheduled_at:)
    notification.schedule(
      schedule_type: schedule_type,
      frequency: frequency,
      scheduled_at: scheduled_at
    )
  end

  def self.process_due_notifications
    NotificationSchedule.due.find_each do |schedule|
      NotificationDeliveryJob.perform_later(schedule.notification_id)
    end
  end

  def self.cancel_notification(notification)
    notification.notification_schedule&.destroy
    notification.update(status: "pending")
  end

  def self.reschedule_notification(notification, new_scheduled_at)
    return false unless notification.notification_schedule

    notification.notification_schedule.update(scheduled_at: new_scheduled_at)
  end
end
