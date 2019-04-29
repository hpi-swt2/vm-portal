# frozen_string_literal: true

require 'rails_helper'

# We should add some tests here, which test that the validation is correct
RSpec.describe AppSetting, type: :model do
  describe 'validation tests' do
    let(:app_setting) {FactoryBot.build :app_setting}

    context 'when settings are invalid' do
      it 'is invalid if it is not the first setting' do
        app_setting.singleton_guard = 1
        expect(app_setting).to be_invalid
      end

      it 'is invalid if the github user email is not a valid mail address' do
        app_setting.github_user_email = 'noEmailAddress'
        expect(app_setting).to be_invalid
      end

      it 'is invalid if the github user name is empty' do
        app_setting.github_user_name = ''
        expect(app_setting).to be_invalid
      end

      it 'is invalid if the git repository name is empty' do
        app_setting.git_repository_name = ''
        expect(app_setting).to be_invalid
      end

      it 'is invalid if the git repository url is empty' do
        app_setting.git_repository_url = ''
        expect(app_setting).to be_invalid
      end

      it 'is invalid if the git branch is empty' do
        app_setting.git_branch = ''
        expect(app_setting).to be_invalid
      end

      it 'is invalid if the smtp port is too high' do
        app_setting.email_notification_smtp_port = 65_536
        expect(app_setting).to be_invalid
      end

      it 'is invalid if the archivation timeout is negative' do
        app_setting.vm_archivation_timeout = -1
        expect(app_setting).to be_invalid
      end

      it 'is invalid if the puppet init path is not a valid UNIX file path' do
        app_setting.puppet_init_path = '/invalid/folder%'
        expect(app_setting).to be_invalid
      end

      it 'is invalid if the puppet classes path is not a valid UNIX file path' do
        app_setting.puppet_classes_path = '\invalid/folder'
        expect(app_setting).to be_invalid
      end

      it 'is invalid if the puppet names path is not a valid UNIX file path' do
        app_setting.puppet_nodes_path = 'invalid/folder#'
        expect(app_setting).to be_invalid
      end

      it 'is invalid if vSphere root folder is too long' do
        app_setting.vsphere_root_folder = '12345678902234567890323456789042345678905234567890623456789072345678908234567890'
        expect(app_setting).to be_invalid
      end

      it 'is invalid if vSphere root folder contains special characters' do
        app_setting.vsphere_root_folder = '/\\%'
        expect(app_setting).to be_invalid
      end
    end

    context 'when settings are valid' do
      it 'is valid with valid attributes' do
        expect(app_setting).to be_valid
      end
    end

  end
end
