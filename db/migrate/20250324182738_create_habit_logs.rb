class CreateHabitLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :habit_logs do |t|
      t.date :date
      t.text :notes
      t.boolean :completed
      t.references :habit, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
