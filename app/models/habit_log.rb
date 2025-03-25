class HabitLog < ApplicationRecord
  belongs_to :habit
  belongs_to :user

  # Validations
  validates :date, presence: true
  validates :completed, inclusion: { in: [ true, false ] }
  validate :user_matches_habit_user

  # Scopes
  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }
  scope :for_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :recent, -> { order(date: :desc) }

  private

  # Ensure the habit belongs to the same user who's logging it
  def user_matches_habit_user
    if habit && user && habit.user_id != user_id
      errors.add(:user, "must match the habit's user")
    end
  end
end
