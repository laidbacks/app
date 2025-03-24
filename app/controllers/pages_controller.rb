class PagesController < ApplicationController
  def signup
  end

  def home
    if logged_in?
      # Get the user's habits (future functionality)
      @user = current_user
      # For demo purposes until habit model is implemented
      @sample_habits = [
        { name: "Morning Meditation", streak: 15, status: "completed" },
        { name: "Read 30 Minutes", streak: 8, status: "pending" },
        { name: "Exercise", streak: 21, status: "pending" },
        { name: "Drink Water", streak: 30, status: "completed" }
      ]

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
end
