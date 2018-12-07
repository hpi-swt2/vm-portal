# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'can be created using the User factory' do
    user = FactoryBot.create(:user)
    expect(user.email).to include '@'
  end

  it 'can be a user' do
    user = FactoryBot.create(:user, role: :user)
    expect(user).to be_user
    expect(user).not_to be_wimi
    expect(user).not_to be_admin
  end

  it 'can be a wimi' do
    user = FactoryBot.create(:user, role: :wimi)
    expect(user).not_to be_user
    expect(user).to be_wimi
    expect(user).not_to be_admin
  end

  it 'can be an admin' do
    user = FactoryBot.create(:user, role: :admin)
    expect(user).not_to be_user
    expect(user).not_to be_wimi
    expect(user).to be_admin
  end

  it 'defaults to user' do
    user = FactoryBot.create :user
    expect(user).to be_truthy
  end
end
