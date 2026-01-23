class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :repository, null: false, foreign_key: true
      t.string :action_type, null: false
      t.integer :commit_count, default: 0
      t.string :ref
      t.string :head_sha
      t.string :before_sha
      t.datetime :occurred_at, null: false

      t.timestamps
    end
    add_index :activities, :action_type
    add_index :activities, :occurred_at
  end
end
