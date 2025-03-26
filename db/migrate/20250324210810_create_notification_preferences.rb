class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :email_enabled, default: true, null: false
      t.boolean :push_enabled, default: true, null: false
      t.boolean :sms_enabled, default: false, null: false
      t.string :email_frequency, default: "immediately", null: false
      t.string :push_frequency, default: "immediately", null: false
      t.string :sms_frequency, default: "immediately", null: false

      t.timestamps
    end
  end
end
