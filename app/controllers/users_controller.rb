class UsersController < ApplicationController
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
    if session[:user_id]
      @user = User.find(session[:user_id])
    else
      redirect_to signup_path, alert: "Please sign up or log in first."
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  helper_method :current_user # Makes this method available in views

  def generate_token(user)
    # Using JWT for token generation
    payload = { user_id: user.id }
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end
  
  def show
    render json: current_user
  end
end
