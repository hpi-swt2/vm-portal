# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'app_settings/edit', type: :view do
  before do
    @app_setting = assign(:app_setting, AppSetting.instance)
  end

  it 'renders the edit app_setting form' do
    render

    assert_select 'form[action=?][method=?]', app_setting_path(@app_setting), 'post' do
      assert_select 'input[name=?]', 'app_setting[git_repository_url]'

      assert_select 'input[name=?]', 'app_setting[git_repository_name]'

      assert_select 'input[name=?]', 'app_setting[github_user_name]'

      assert_select 'input[name=?]', 'app_setting[github_user_email]'

      assert_select 'input[name=?]', 'app_setting[vsphere_server_ip]'

      assert_select 'input[name=?]', 'app_setting[vsphere_server_user]'

      assert_select 'input[name=?]', 'app_setting[vsphere_server_password]'

      assert_select 'input[name=?]', 'app_setting[email_notification_smtp_address]'

      assert_select 'input[name=?]', 'app_setting[email_notification_smtp_port]'

      assert_select 'input[name=?]', 'app_setting[email_notification_smtp_domain]'

      assert_select 'input[name=?]', 'app_setting[email_notification_smtp_user]'

      assert_select 'input[name=?]', 'app_setting[email_notification_smtp_password]'

      assert_select 'input[name=?]', 'app_setting[vm_archivation_timeout]'
    end
  end
end
