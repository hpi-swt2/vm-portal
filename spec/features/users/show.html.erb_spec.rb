# frozen_string_literal: true

require 'rails_helper'

describe 'users/show.html.erb', type: :feature do
  let(:another_user) { FactoryBot.create :user }

  context 'when the user is not an admin' do
    let(:user) { FactoryBot.create :user }

    before do
      sign_in user
    end

    context 'when visits his profile' do
      before do
        visit user_path(user)
      end

      it 'does not redirect' do
        expect(page).to have_current_path(user_path(user))
      end
    end

    context 'when visits another users profile' do
      before do
        visit user_path(another_user)
      end

      it 'redirects to the dashboard' do
        expect(page).to have_current_path dashboard_path
      end
    end
  end

  context 'when the user is an admin' do
    let(:admin) { FactoryBot.create :admin }

    before do
      sign_in admin
    end

    context 'when the user visits another users profile' do
      before do
        visit user_path(another_user)
      end

      it 'does not redirect' do
        expect(page).to have_current_path(user_path(another_user))
      end
    end
  end
end
