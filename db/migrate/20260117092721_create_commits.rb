class CreateCommits < ActiveRecord::Migration[8.1]
  def change
    create_table :commits do |t|
      t.string :sha, null: false
      t.references :repository, null: false, foreign_key: true
      t.references :user, foreign_key: true # Optional: linked if email matches
      t.string :author_name
      t.string :author_email, null: false
      t.text :message
      t.datetime :committed_at, null: false
      t.jsonb :parent_shas, default: []

      t.timestamps
    end
    add_index :commits, :sha
    add_index :commits, :author_email
    add_index :commits, :committed_at
    add_index :commits, [:repository_id, :sha], unique: true
  end
end
