class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :full_name, :string
    add_column :users, :bio, :text
    add_column :users, :timezone, :string
    add_column :users, :avatar, :string
  end
end
