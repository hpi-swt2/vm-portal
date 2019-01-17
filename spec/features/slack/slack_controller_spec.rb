# frozen_string_literal: true

require 'rails_helper'

describe SlackController do
  it 'renders an error if you are not logged in' do
    visit update_slack_path

    expect(page).to have_text 'sign in'
  end

  def mock_sign_in
    user = FactoryBot.create :user
    sign_in(user)
    user
  end

  def mock_auth_request
    mock_sign_in.slack_auth_requests.create state: 'This is a state'
  end

  it 'renders an error if the state is invald' do
    mock_sign_in
    visit update_slack_path

    expect(page).to have_content 'Error'
  end

  it 'renders an error if the authentication code is missing' do
    auth_request = mock_auth_request
    visit update_slack_path(state: auth_request.state)

    expect(page).to have_content 'Error'
  end

  it 'renders an error if slack cannot be reached' do
    auth_request = mock_auth_request
    allow(Net::HTTP).to receive(:post_form).and_raise('Slack could not be reached!')

    visit update_slack_path(state: auth_request.state, code: 'We must provide a code')

    expect(page).to have_content 'Error'
  end

  it 'renders an error if slack returns an error' do
    auth_request = mock_auth_request

    error_message = 'My Error'
    described_class.any_instance.stub(:authenticate_request).and_return('ok' => false, 'error' => error_message)
    # see https://api.slack.com/methods/oauth.access for the protocol of the mocked api

    visit update_slack_path(state: auth_request.state, code: 'We must provide a code')

    expect(page).to have_content error_message
  end

  it 'shows success message' do
    auth_request = mock_auth_request

    described_class.any_instance.stub(:authenticate_request).and_return('incoming_webhook' => { 'url' => 'My URL' })
    # see https://api.slack.com/methods/oauth.access for the protocol of the mocked api

    visit update_slack_path(state: auth_request.state, code: 'We must provide a code')

    expect(page).to have_content 'success'
  end

  it 'can successfully create a new slack hook' do
    auth_request = mock_auth_request

    webhook_url = 'My URL'
    described_class.any_instance.stub(:authenticate_request).and_return('incoming_webhook' => { 'url' => webhook_url })
    # see https://api.slack.com/methods/oauth.access for the protocol of the mocked api

    visit update_slack_path(state: auth_request.state, code: 'We must provide a code')

    expect(auth_request.user.slack_hooks.map(&:url)).to include(webhook_url)
  end
end
