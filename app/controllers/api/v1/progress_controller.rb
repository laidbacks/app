module Api
  module V1
    class ProgressController < ApplicationController
      before_action :authenticate_user

      def index
        habits = current_user.habits.active
        progress_data = habits.map do |habit|
          {
            id: habit.id,
            name: habit.name,
            frequency: habit.frequency,
            current_streak: habit.current_streak,
            best_streak: habit.best_streak,
            completion_rate: habit.completion_rate,
            completion_rate_7_days: habit.completion_rate(7.days.ago.beginning_of_day),
            completion_rate_30_days: habit.completion_rate(30.days.ago.beginning_of_day)
          }
        end

        render json: {
          habits: progress_data,
          total_habits: habits.count,
          average_completion_rate: calculate_average_completion_rate(habits),
          total_current_streaks: calculate_total_current_streaks(habits)
        }
      end

      private

      def calculate_average_completion_rate(habits)
        return 0 if habits.empty?

        total_rate = habits.sum { |habit| habit.completion_rate }
        (total_rate / habits.count).round(2)
      end

      def calculate_total_current_streaks(habits)
        habits.sum(&:current_streak)
      end
    end
  end
end
