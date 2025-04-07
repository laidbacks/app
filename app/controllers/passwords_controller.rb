class PasswordsController < ApplicationController
  before_action :require_login

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    # Check if the current password matches
    if @user.authenticate(params[:current_password])
      # Validate password confirmation
      if params[:password] == params[:password_confirmation]
        if @user.update(password: params[:password])
          flash[:notice] = "Password updated successfully."
          redirect_to settings_path
        else
          flash.now[:alert] = "Error: #{@user.errors.full_messages.join(', ')}"
          render :edit, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = "Error: Password confirmation doesn't match."
        render :edit, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Error: Current password is incorrect."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this section"
      redirect_to login_path
    end
  end
end
