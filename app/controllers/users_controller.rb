class UsersController < ApplicationController
  before_action :require_login, only: [:show]

  def new
    @user = User.new
    render :signup
  end

  def signup
    @user = User.new
    render :signup
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      redirect_to profile_path, notice: "Account created successfully!"
    else
      render :signup, status: :unprocessable_entity
    end
  end

  def show
    @user = current_user
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

  def generate_token(user)
    # Using JWT for token generation
    payload = { user_id: user.id }
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
end
