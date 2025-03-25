module Api
  class HabitLogsController < ApplicationController
    before_action :authenticate_user
    before_action :set_habit_log, only: [ :show, :update, :destroy ]

    # GET /api/habit_logs
    def index
      if params[:habit_id]
        @habit = current_user.habits.find(params[:habit_id])
        @habit_logs = @habit.habit_logs
      else
        @habit_logs = current_user.habit_logs
      end

      # Filter by date range if provided
      if params[:start_date].present? && params[:end_date].present?
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])
        @habit_logs = @habit_logs.for_date_range(start_date, end_date)
      end

      # Filter by completion status if provided
      if params[:completed].present?
        completed = ActiveModel::Type::Boolean.new.cast(params[:completed])
        @habit_logs = completed ? @habit_logs.completed : @habit_logs.incomplete
      end

      @habit_logs = @habit_logs.recent # Order by most recent

      render json: @habit_logs
    end

    # GET /api/habit_logs/:id
    def show
      render json: @habit_log
    end

    # POST /api/habit_logs
    def create
      @habit = current_user.habits.find(params[:habit_id])
      @habit_log = @habit.habit_logs.build(habit_log_params)
      @habit_log.user = current_user

      if @habit_log.save
        render json: @habit_log, status: :created
      else
        render json: { errors: @habit_log.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/habit_logs/:id
    def update
      if @habit_log.update(habit_log_params)
        render json: @habit_log
      else
        render json: { errors: @habit_log.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/habit_logs/:id
    def destroy
      @habit_log.destroy
      head :no_content
    end

    # PATCH /api/habits/:habit_id/toggle_today
    def toggle_today
      @habit = current_user.habits.find(params[:habit_id])
      @today_log = @habit.habit_logs.find_or_initialize_by(date: Date.today, user: current_user)

      # Toggle completion status
      @today_log.completed = !@today_log.completed? if @today_log.persisted?
      @today_log.completed = true unless @today_log.persisted?

      if @today_log.save
        render json: @today_log
      else
        render json: { errors: @today_log.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_habit_log
      @habit_log = current_user.habit_logs.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Habit log not found" }, status: :not_found
    end

    def habit_log_params
      params.require(:habit_log).permit(:date, :notes, :completed)
    end
  end
end
