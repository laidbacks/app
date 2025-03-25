class HabitsController < ApplicationController
  before_action :require_login
  before_action :set_habit, only: [ :show, :edit, :update, :destroy, :toggle_today ]

  # GET /habits
  def index
    @habits = current_user.habits.order(created_at: :desc)
  end

  # GET /habits/:id
  def show
    # The habit is loaded in set_habit
  end

  # GET /habits/new
  def new
    @habit = current_user.habits.new
  end

  # GET /habits/:id/edit
  def edit
    # The habit is loaded in set_habit
  end

  # POST /habits
  def create
    @habit = current_user.habits.new(habit_params)

    if @habit.save
      redirect_to habits_path, notice: "Habit was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /habits/:id
  def update
    if @habit.update(habit_params)
      redirect_to habit_path(@habit), notice: "Habit was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /habits/:id
  def destroy
    @habit.destroy
    redirect_to habits_path, notice: "Habit was successfully deleted."
  end

  # PATCH /habits/:id/toggle_today
  def toggle_today
    # Check if there's a log for today
    today = Date.today
    log = @habit.habit_logs.find_or_initialize_by(date: today)

    # Set the user association
    log.user = current_user

    # Toggle the completed status
    log.completed = !log.completed

    if log.save
      redirect_to request.referer || habits_path, notice: "Habit status updated."
    else
      redirect_to request.referer || habits_path, alert: log.errors.full_messages.join(", ")
    end
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to habits_path, alert: "Habit not found"
  end

  def habit_params
    params.require(:habit).permit(:name, :description, :frequency, :active)
  end
end
