require 'rails_helper'

describe 'SlackController' do
  it 'renders an error if state is missing' do
    visit update_slack_path
  end
end