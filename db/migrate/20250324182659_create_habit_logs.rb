class CreateHabitLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :habit_logs do |t|
      t.references :habit, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.boolean :completed, default: false
      t.text :notes

      t.timestamps
    end
    add_index :habit_logs, [ :habit_id, :date ], unique: true
  end
end
