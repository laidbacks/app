class SessionsController < ApplicationController
  def new
    # Display login form
  end

  def create
    user = User.find_by(username: params[:username])
    
    if user && user.authenticate(params[:password])
      # Login successful - set the user id in session
      session[:user_id] = user.id
      redirect_to profile_path, notice: "Logged in successfully!"
    else
      # Login failed - show error message
      flash.now[:alert] = "Invalid username or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # Logout - clear the session
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out successfully!"
  end
end 