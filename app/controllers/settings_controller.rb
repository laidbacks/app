class SettingsController < ApplicationController
  before_action :require_login
  before_action :set_setting, only: [ :show, :update ]

  def show
    respond_to do |format|
      format.html
      format.json { render json: @setting }
    end
  end

  def update
    respond_to do |format|
      if @setting.update(setting_params)
        format.html { redirect_to settings_path, notice: "Settings updated successfully." }
        format.json { render json: @setting }
      else
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: { errors: @setting.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_setting
    @setting = current_user.setting || current_user.create_setting(Setting.default_settings)
  end

  def setting_params
    params.require(:setting).permit(:theme, :notifications_enabled, :email_notifications_enabled)
  end
end
