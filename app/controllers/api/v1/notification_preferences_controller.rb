class Api::V1::NotificationPreferencesController < ApplicationController
  before_action :authenticate_user

  def show
    # Create default preferences if they don't exist
    ensure_preferences_exist

    # Return the user's notification preferences
    render json: current_user.notification_preference
  end

  def update
    # Create/load preferences
    ensure_preferences_exist

    if @preferences.update(preference_params)
      render json: @preferences
    else
      render json: { errors: @preferences.errors }, status: :unprocessable_entity
    end
  end

  private

  def ensure_preferences_exist
    @preferences = current_user.notification_preference || current_user.create_notification_preference(
      email_enabled: true,
      push_enabled: true,
      sms_enabled: false,
      email_frequency: "daily_digest",
      push_frequency: "immediately",
      sms_frequency: "immediately"
    )
  end

  def preference_params
    params.require(:preferences).permit(
      :email_enabled,
      :push_enabled,
      :sms_enabled,
      :email_frequency,
      :push_frequency,
      :sms_frequency,
      :phone_number
    )
  end
end
