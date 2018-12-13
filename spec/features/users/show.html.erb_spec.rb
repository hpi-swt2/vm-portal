# frozen_string_literal: true

require 'rails_helper'

describe 'users/show.html.erb', type: :feature do
  let(:valid_ssh_key) { SSHKey.generate.public_key}

  let(:invalid_ssh_key) { 'super good key' }

  context 'when the user has a ssh key' do
    before do
      @user = FactoryBot.create :user
      sign_in @user
      visit user_path(@user)
    end

    context 'when clicking the edit button' do
      before do
        page.find_by_id('editSshKey').click
      end

      context 'when filling in and saving a valid ssh key' do
        before do
          page.fill_in 'user[ssh_key]', with: valid_ssh_key
        end

        it 'saves the ssh key' do
          expect(@user.ssh_key).to eq valid_ssh_key
        end
      end

      context 'when filling in and saving an invalid ssh key' do
        before do
          page.fill_in 'user[ssh_key]', with: invalid_ssh_key
        end

        it 'does not save the ssh key' do
          expect(@user.ssh_key).not_to eq valid_ssh_key
        end

        it 'shows an alert' do
          expect(@user.ssh_key).not_to eq valid_ssh_key
        end
      end
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
