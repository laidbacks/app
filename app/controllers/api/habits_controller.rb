module Api
  class HabitsController < ApplicationController
    before_action :authenticate_user
    before_action :set_habit, only: [ :show, :update, :destroy ]

    # GET /api/habits
    def index
      @habits = current_user.habits
      render json: @habits
    end

    # GET /api/habits/:id
    def show
      render json: @habit
    end

    # POST /api/habits
    def create
      @habit = current_user.habits.build(habit_params)

      if @habit.save
        render json: @habit, status: :created
      else
        render json: { errors: @habit.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/habits/:id
    def update
      if @habit.update(habit_params)
        render json: @habit
      else
        render json: { errors: @habit.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/habits/:id
    def destroy
      @habit.destroy
      head :no_content
    end

    # GET /api/habits/:id/stats
    def stats
      @habit = current_user.habits.find(params[:id])
      start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 30.days.ago.to_date
      end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

      completion_rate = @habit.completion_rate(start_date, end_date)

      render json: {
        completion_rate: completion_rate,
        habit_id: @habit.id,
        period: {
          start_date: start_date,
          end_date: end_date
        }
      }
    end

    private

    def set_habit
      @habit = current_user.habits.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Habit not found" }, status: :not_found
    end

    def habit_params
      params.require(:habit).permit(:name, :description, :frequency, :active)
    end
  end
end
