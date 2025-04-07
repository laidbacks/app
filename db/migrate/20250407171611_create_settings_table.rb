class CreateSettingsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :theme, default: 'system'
      t.boolean :notifications_enabled, default: true
      t.boolean :email_notifications_enabled, default: true
      t.timestamps
    end

    add_index :settings, :user_id, unique: true
  rescue ActiveRecord::StatementInvalid => e
    if e.message.include?('already exists')
      say "Settings table already exists, skipping"
    else
      raise e
    end
  end
end
