# frozen_string_literal: true

require 'rails_helper'

describe 'users/edit.html.erb', type: :feature do
  let(:invalid_ssh_key) { 'super good key' }

  let(:user) { FactoryBot.create :user }

  before do
    sign_in user
    visit edit_user_path(user)
  end

  context 'when the user is the current user' do
    let(:valid_ssh_key) { SSHKey.generate.ssh_public_key }

    it 'shows the user ssh-key' do
      expect(page).to have_text(user.ssh_key)
    end

    it 'lets you change the ssh key' do
      page.fill_in 'user[ssh_key]', with: valid_ssh_key
      page.click_button('saveUserButton')
      user.reload
      expect(user.ssh_key).to eq valid_ssh_key
    end

    context 'when the new ssh key is invalid' do
      before do
        page.fill_in 'user[ssh_key]', with: invalid_ssh_key
        page.click_button('saveUserButton')
      end

      it 'shows an error message' do
        expect(page).to have_css '.alert-danger'
      end

      it 'does not let change the ssh key' do
        user.reload
        expect(user.ssh_key).not_to eq invalid_ssh_key
      end
    end
  end

  context 'when the requested user is not the current user' do
    let(:other_user) { FactoryBot.create :user }

    before do
      visit edit_user_path(other_user)
    end

    it 'redirects to the dashboard' do
      expect(page).to have_current_path dashboard_path
    end
  end
end
