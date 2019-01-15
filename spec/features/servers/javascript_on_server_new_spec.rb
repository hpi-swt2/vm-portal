require 'rails_helper'

RSpec.describe 'On new server page', type: :feature do
  # Authenticate an user
  before do
    sign_in FactoryBot.create :user, role: :admin
  end
  
  it 'adds a text input on Add Software button click' do
    visit new_server_path
    click_button('Add Software')
    assert_select 'input[name=?]', 'software1'
  end
end