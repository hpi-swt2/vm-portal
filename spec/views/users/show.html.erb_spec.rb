# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/show.html.erb', type: :view do
  let(:user) { FactoryBot.create :user }

  before do
    assign(:user, user)
    render
  end

  it 'shows the users name' do
    expect(rendered).to include user.name
  end

  it 'shows the users email' do
    expect(rendered).to include user.email
  end

  context 'when the requested user is the current user' do
    before do
      allow(view).to receive(:current_user).and_return(user)
      render
    end
    it 'shows an edit button' do
      expect(rendered).to have_link(id: 'editUserButton', href: edit_user_path(user))
    end

    context 'when the user has a ssh key' do
      it 'shows the ssh key' do
        expect(rendered).to include user.ssh_key
      end
    end

    context 'when the user has no ssh key' do
      let(:user) { FactoryBot.create :user, ssh_key: '' }

      it 'shows a no ssh-key text' do
        expect(rendered).to include 'No SSH-Key'
      end
    end
  end


  context 'when the requested user is not the current user' do
    let(:other_user) { FactoryBot.create :user, ssh_key: 'bla' }

    before do
      allow(view).to receive(:current_user).and_return(other_user)
      render
    end

    it 'does not show the ssh-key' do
      expect(rendered).not_to include user.ssh_key
    end

    it 'does not show the edit-button' do
      expect(rendered).not_to have_link(id: 'editUserButton', href: edit_user_path(user))
    end
  end
end
