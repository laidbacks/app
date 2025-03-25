class HabitLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit_log, only: [ :show, :edit, :update, :destroy ]

  # GET /habits/:habit_id/habit_logs
  def index
    @habit = current_user.habits.find(params[:habit_id])
    @habit_logs = @habit.habit_logs.order(date: :desc)
  end

  # GET /habit_logs/:id
  def show
    # @habit_log loaded in set_habit_log
  end

  # GET /habits/:habit_id/habit_logs/new
  def new
    @habit = current_user.habits.find(params[:habit_id])
    @habit_log = @habit.habit_logs.new(date: Date.today)
  end

  # GET /habit_logs/:id/edit
  def edit
    # @habit_log loaded in set_habit_log
  end

  # POST /habits/:habit_id/habit_logs
  def create
    @habit = current_user.habits.find(params[:habit_id])
    @habit_log = @habit.habit_logs.new(habit_log_params)

    # Check if there's already a log for this date
    existing_log = @habit.habit_logs.find_by(date: @habit_log.date)
    if existing_log
      existing_log.update(habit_log_params)
      redirect_to habit_path(@habit), notice: "Habit log was successfully updated."
      return
    end

    if @habit_log.save
      redirect_to habit_path(@habit), notice: "Habit log was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /habit_logs/:id
  def update
    if @habit_log.update(habit_log_params)
      redirect_to habit_path(@habit_log.habit), notice: "Habit log was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /habit_logs/:id
  def destroy
    habit = @habit_log.habit
    @habit_log.destroy
    redirect_to habit_path(habit), notice: "Habit log was successfully deleted."
  end

  private

  def set_habit_log
    @habit_log = HabitLog.find(params[:id])

    # Ensure the habit log belongs to the current user
    unless @habit_log.habit.user_id == current_user.id
      redirect_to habits_path, alert: "You don't have permission to access this log."
    end
  end

  def habit_log_params
    params.require(:habit_log).permit(:date, :completed, :notes)
  end
end
