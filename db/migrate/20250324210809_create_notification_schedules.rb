class CreateNotificationSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_schedules do |t|
      t.references :notification, null: false, foreign_key: true
      t.string :schedule_type, null: false
      t.string :frequency, null: false
      t.datetime :scheduled_at, null: false
      t.datetime :last_sent_at

      t.timestamps
    end

    add_index :notification_schedules, :schedule_type
    add_index :notification_schedules, :frequency
    add_index :notification_schedules, :scheduled_at
  end
end
