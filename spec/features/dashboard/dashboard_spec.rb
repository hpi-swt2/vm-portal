# frozen_string_literal: true

require 'rails_helper'

describe 'Dashboard', type: :feature do
  it 'does not render when no user is signed in' do
    expect(page).to match(render '/users/sign_up')
  end

  it 'does render when a user is signed in' do
    pending('mock user sign in')
    expect(page).to match(render '/dashboard')
  end
end
