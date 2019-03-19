class AddGitBranchToAppSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :app_settings, :git_branch, :string, default: 'master'
  end
end
