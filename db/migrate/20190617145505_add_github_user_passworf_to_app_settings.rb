class AddGithubUserPassworfToAppSettings < ActiveRecord::Migration[5.2]
  def change
  	rename_column :app_settings, :github_user_email, :github_user_password
  end
end
