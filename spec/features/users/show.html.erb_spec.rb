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
      expect(page).to have(user.ssh_key)
    end

  end

  # context 'when the user has no ssh key' do
  #   before do
  #     @user = FactoryBot.create :user, ssh_key: ''
  #     visit user_path(@user)
  #   end
  #
  #   context 'when clicking the add button' do
  #     before do
  #       p page
  #       page.find_by_id('editSshKey').click
  #     end
  #
  #     it 'works' do
  #       false
  #     end
  #   end
  # end
end
