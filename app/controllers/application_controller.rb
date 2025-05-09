class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Skip CSRF protection for API endpoints
  skip_before_action :verify_authenticity_token, if: :json_request?

  # Make these helpers available to views
  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page"
      redirect_to login_path
    end
  end

  def authenticate_user
    unless logged_in?
      render json: { error: "You must be logged in to access this endpoint" }, status: :unauthorized
    end
  end

  def json_request?
    request.format.json? ||
    request.path.include?("/api/") ||
    request.content_type == "application/json"
  end
end
