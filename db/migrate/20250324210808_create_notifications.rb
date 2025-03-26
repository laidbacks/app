class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body, null: false
      t.string :notification_type, null: false
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :notifications, :status
    add_index :notifications, :notification_type
  end
end
