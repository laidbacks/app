class PagesController < ApplicationController
  def signup
  end

  def home
    if logged_in?
      # Get the user's habits (loaded server-side)
      @user = current_user
      @habits = current_user.habits.order(created_at: :desc)

      # Find strongest habit
      @strongest_habit = @habits.max_by { |h| h.current_streak || 0 }

      # Quote of the day
      @quotes = [
        "The secret of getting ahead is getting started. – Mark Twain",
        "Small habits make a big difference. – James Clear",
        "We are what we repeatedly do. Excellence, then, is not an act, but a habit. – Aristotle",
        "Success is the sum of small efforts, repeated day in and day out. – Robert Collier",
        "Your habits become your values, your values become your destiny. – Mahatma Gandhi",
        "Champions keep playing until they get it right. – Billie Jean King"
      ]
      @quote = @quotes.sample

      render :dashboard
    else
      # Show the landing page for non-logged in users
      render :landing
    end
  end

  # Redirect old routes to new controller
  def habits
    redirect_to habits_path
  end

  def habit_detail
    redirect_to habit_path(params[:id])
  end
end
