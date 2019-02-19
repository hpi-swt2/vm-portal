require 'rails_helper'

RSpec.describe "app_settings/edit", type: :view do
  before(:each) do
    @app_setting = assign(:app_setting, AppSetting.create!(
      :singleton_guard => 1,
      :git_repository_url => "MyString",
      :git_repository_name => "MyString",
      :github_user_name => "MyString",
      :github_user_email => "MyString",
      :vsphere_server_ip => "MyString",
      :vsphere_server_user => "MyString",
      :vsphere_server_password => "MyString",
      :email_notification_smtp_address => "MyString",
      :email_notification_smtp_port => 1,
      :email_notification_smtp_domain => "MyString",
      :email_notification_smtp_user => "MyString",
      :email_notification_smtp_password => "MyString",
      :vm_archivation_timeout => 1
    ))
  end

  it "renders the edit app_setting form" do
    render

    assert_select "form[action=?][method=?]", app_setting_path(@app_setting), "post" do

      assert_select "input[name=?]", "app_setting[singleton_guard]"

      assert_select "input[name=?]", "app_setting[git_repository_url]"

      assert_select "input[name=?]", "app_setting[git_repository_name]"

      assert_select "input[name=?]", "app_setting[github_user_name]"

      assert_select "input[name=?]", "app_setting[github_user_email]"

      assert_select "input[name=?]", "app_setting[vsphere_server_ip]"

      assert_select "input[name=?]", "app_setting[vsphere_server_user]"

      assert_select "input[name=?]", "app_setting[vsphere_server_password]"

      assert_select "input[name=?]", "app_setting[email_notification_smtp_address]"

      assert_select "input[name=?]", "app_setting[email_notification_smtp_port]"

      assert_select "input[name=?]", "app_setting[email_notification_smtp_domain]"

      assert_select "input[name=?]", "app_setting[email_notification_smtp_user]"

      assert_select "input[name=?]", "app_setting[email_notification_smtp_password]"

      assert_select "input[name=?]", "app_setting[vm_archivation_timeout]"
    end
  end
end
