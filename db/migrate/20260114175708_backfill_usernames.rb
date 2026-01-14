class BackfillUsernames < ActiveRecord::Migration[8.1]
  def up
    User.where(username: nil).find_each do |user|
      base_username = user.email_address.split('@').first.gsub(/[^a-zA-Z0-9_\-]/, '_')[0..38]
      username = base_username
      counter = 1

      while User.exists?(username: username)
        suffix = "_#{counter}"
        username = "#{base_username[0..(38 - suffix.length)]}#{suffix}"
        counter += 1
      end

      user.update_columns(username: username)
    end
  end

  def down
    # Nothing to do
  end
end
