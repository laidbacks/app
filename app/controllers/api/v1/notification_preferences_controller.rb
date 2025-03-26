class Api::V1::NotificationPreferencesController < ApplicationController
  before_action :authenticate_user

  def show
    render json: current_user.notification_preferences
  end

  def update
    @preferences = current_user.notification_preferences || current_user.build_notification_preferences

    if @preferences.update(preference_params)
      render json: @preferences
    else
      render json: { errors: @preferences.errors }, status: :unprocessable_entity
    end
  end

  private

  def preference_params
    params.require(:preferences).permit(
      :email_enabled,
      :push_enabled,
      :sms_enabled,
      :email_frequency,
      :push_frequency,
      :sms_frequency
    )
  end
end
