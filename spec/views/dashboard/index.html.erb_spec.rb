# frozen_string_literal: true

require 'rails_helper'

describe 'Dashboard', type: :view do
  it 'does not render when no user is signed in' do
    pending('check for sign up page at /')
    render '/'
  end

  it 'does render when a user is signed in' do
    pending('check for dashboard page at /')
    render '/'
  end

  it 'does render a list of all available vms for a signed in user' do
    pending('mock user with non-empty vm list')
    render '/'
  end

  it 'does render an empty list if a user does not have access to a vm' do
    pending('mock user with empty vm list')
    render '/'
  end

  it 'does render a selection of details per vm' do
    pending('wait for desired list of details in general and for dashboard')
    render '/'
  end
end