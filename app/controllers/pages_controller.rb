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
        "Most people overestimate what they can do in one year and underestimate what they can do in ten. – Bill Gates",
        "Move fast and break things. Unless you are breaking stuff, you are not moving fast enough. – Mark Zuckerberg",
        "There is nothing impossible to him who will try. – Alexander the Great",
        "Persistence is very important. You should not give up unless you are forced to give up. – Elon Musk",
        "I'm convinced that about half of what separates the successful entrepreneurs from the non-successful ones is pure perseverance. – Steve Jobs",
        "You earn reputation by trying to do hard things well. – Jeff Bezos",
        "Genius is one percent inspiration and ninety-nine percent perspiration. – Thomas Edison",
        "The future rewards those who press on. I don't have time to feel sorry for myself. I don't have time to complain. I'm going to press on. – Barack Obama",
        "The man who moves a mountain begins by carrying away small stones. – Confucius",
        "I fear not the man who has practiced 10,000 kicks once, but I fear the man who has practiced one kick 10,000 times. – Bruce Lee"
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
