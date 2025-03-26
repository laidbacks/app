class NotificationsController < ApplicationController
  before_action :require_login
  before_action :set_notification, only: [ :edit, :schedule ]

  def index
    # Render the notification settings page
    # The actual data fetching happens via JS
  end

  def new
    @notification = current_user.notifications.build
  end

  def create
    @notification = current_user.notifications.build(notification_params)

    if @notification.save
      # Check if the user came from the profile page
      if request.referer&.include?("/profile")
        redirect_to profile_path(notification_created: true), notice: "Notification was successfully created."
      else
        redirect_to notifications_path(notification_created: true), notice: "Notification was successfully created."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Render the edit page
    # The actual data fetching and update happens via JS
  end

  def schedule
    # Render the schedule page
    # The actual scheduling happens via JS
  end

  def delete_all
    current_user.notifications.destroy_all
    redirect_to notifications_path, notice: "All notifications have been deleted."
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to notifications_path, alert: "Notification not found"
  end

  def notification_params
    params.require(:notification).permit(:title, :body, :notification_type)
  end
end
