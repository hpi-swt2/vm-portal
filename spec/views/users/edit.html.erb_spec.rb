# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users/edit.html.erb', type: :view do
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

    context 'when the user has a ssh key' do
      it 'shows the ssh key' do
        expect(rendered).to include user.ssh_key
      end
    end
  end
end
