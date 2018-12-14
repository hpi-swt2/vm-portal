# frozen_string_literal: true

require 'rails_helper'

describe 'users/show.html.erb', type: :feature do
  let(:invalid_ssh_key) { 'super good key' }

  let(:user) { FactoryBot.create :user }

  before do
    sign_in user
    visit user_path(user)
  end

  context 'when the user has a ssh key' do

    it 'shows the user ssh-key' do
      expect(page).to have_content(user.ssh_key)
    end
  end

end
