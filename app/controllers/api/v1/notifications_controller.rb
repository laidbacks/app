class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate_user
  before_action :set_notification, only: [ :show, :update, :destroy, :schedule, :cancel ]

  def index
    @notifications = current_user.notifications
    render json: @notifications
  end

  def stats
    stats = {
      scheduled: current_user.notifications.scheduled.count,
      pending: current_user.notifications.pending.count,
      sent: current_user.notifications.sent.count,
      failed: current_user.notifications.failed.count,
      total: current_user.notifications.count
    }
    render json: stats
  end

  def show
    render json: @notification
  end

  def create
    @notification = current_user.notifications.build(notification_params)

    if @notification.save
      render json: @notification, status: :created
    else
      render json: { errors: @notification.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @notification.update(notification_params)
      render json: @notification
    else
      render json: { errors: @notification.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @notification.destroy
    head :no_content
  end

  def schedule
    if NotificationScheduler.schedule_notification(
      notification: @notification,
      schedule_type: schedule_params[:schedule_type],
      frequency: schedule_params[:frequency],
      scheduled_at: schedule_params[:scheduled_at]
    )
      render json: @notification
    else
      render json: { errors: @notification.errors }, status: :unprocessable_entity
    end
  end

  def cancel
    if NotificationScheduler.cancel_notification(@notification)
      render json: @notification
    else
      render json: { errors: @notification.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Notification not found" }, status: :not_found
  end

  def notification_params
    params.require(:notification).permit(:title, :body, :notification_type)
  end

  def schedule_params
    params.require(:schedule).permit(:schedule_type, :frequency, :scheduled_at)
  end
end
