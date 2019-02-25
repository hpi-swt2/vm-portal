# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe AppSettingsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # AppSetting. As you add validations to AppSetting, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      git_repository_url: 'test',
      git_repository_name: 'test',
      github_user_name: 'test',
      github_user_email: 'gummybear@space.tld',
      vsphere_server_ip: '127.0.0.1',
      vsphere_server_user: 'gozsdgfou2!§hdsfj',
      vsphere_server_password: '6§$%95r9v932',
      vsphere_root_folder: 'my-root-folder-----------------------------------------------------------------', # 79 chars are allowed
      email_notification_smtp_address: 'smtp.email.com',
      email_notification_smtp_port: '1234',
      email_notification_smtp_domain: 'email.com',
      email_notification_smtp_user: 'myUser',
      email_notification_smtp_password: 'verySecure',
      vm_archivation_timeout: '120'
    }
  end

  let(:invalid_attributes) do
    valid_attributes.merge(
      github_user_email: 'helloWorld',
      email_notification_smtp_port: 'NoInteger',
      vm_archivation_timeout: 'NoInteger2',
      vsphere_root_folder: 'ThisIsATooLongStringThatContains/\%WhichIsInvalid...............................' # 80 chars are not allowed
    )
  end

  before do
    sign_in FactoryBot.create(:admin)
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      app_setting = AppSetting.instance
      get :edit, params: { id: app_setting.to_param }
      expect(response).to be_successful
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested app_setting' do
        app_setting = AppSetting.instance
        put :update, params: { id: app_setting.to_param, app_setting: valid_attributes }
        app_setting.reload
        expect(app_setting.vsphere_server_password).to eql(valid_attributes[:vsphere_server_password])
      end

      it 'redirects to the app_setting' do
        app_setting = AppSetting.instance
        put :update, params: { id: app_setting.to_param, app_setting: valid_attributes }
        expect(response).to redirect_to(edit_app_setting_path(app_setting))
      end

      it 'updates the mailer settings' do
        ActionMailer::Base.smtp_settings[:address] = 'Hello World!'
        put :update, params: { id: AppSetting.instance.to_param, app_setting: valid_attributes }
        expect(ActionMailer::Base.smtp_settings[:address]).to eql(valid_attributes[:email_notification_smtp_address])
      end

      it 'resets the git settings' do
        allow(GitHelper).to receive(:reset)
        put :update, params: { id: AppSetting.instance.to_param, app_setting: valid_attributes }
        expect(GitHelper).to have_received(:reset)
      end

      it 'can update the vSphere root folder' do
        put :update, params: { id: AppSetting.instance.to_param, app_setting: valid_attributes }
        expect(AppSetting.instance.vsphere_root_folder).to eql(valid_attributes[:vsphere_root_folder])
        AppSetting.instance.update!(vsphere_root_folder: '') # Make sure that we use the default root folder during the tests
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'edit' template)" do
        app_setting = AppSetting.instance
        put :update, params: { id: app_setting.to_param, app_setting: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end
end
