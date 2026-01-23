class MakeUserIdNotNullOnCommits < ActiveRecord::Migration[8.1]
  def change
    change_column_null :commits, :user_id, false
  end
end
