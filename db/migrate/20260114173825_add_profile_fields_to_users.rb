class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string
    add_index :users, :username, unique: true
    add_column :users, :full_name, :string
    add_column :users, :bio, :text
    add_column :users, :company, :string
    add_column :users, :location, :string
    add_column :users, :website, :string
    add_column :users, :twitter_handle, :string
    add_column :users, :status, :string
  end
end
