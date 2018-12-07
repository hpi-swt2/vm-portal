# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show.html.erb', type: :feature do
  let(:user) { FactoryBot.create :user }

  before do
    assign(:user, user)
    allow(view).to receive(:current_user).and_return(user)
    render
  end


  context 'when the user has a ssh key' do
    it 'shows the ssh key' do
      expect(rendered).to include user.ssh_key
    end

    it 'shows a button for editing' do
      expect(rendered).to have_button('Edit')
    end
  end

  context 'when the user has no ssh key' do
    let(:user) { FactoryBot.create :user, ssh_key: '' }

    it 'shows a button for adding' do
      expect(rendered).to have_button('Add')
    end
  end
end
