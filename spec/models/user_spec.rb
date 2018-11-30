# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it 'can be created using the User factory' do
    user = FactoryBot.create(:user)
    expect(user.email).to include '@'
  end

  it 'can be a user' do
    user = FactoryBot.create(:user, role: :user)
    expect(user.user?).to be_truthy
    expect(user.wimi?).to be_falsey
    expect(user.admin?).to be_falsey
  end

  it 'can be a wimi' do
    user = FactoryBot.create(:user, role: :wimi)
    expect(user.user?).to be_falsey
    expect(user.wimi?).to be_truthy
    expect(user.admin?).to be_falsey
  end

  it 'can be an admin' do
    user = FactoryBot.create(:user, role: :admin)
    expect(user.user?).to be_falsey
    expect(user.wimi?).to be_falsey
    expect(user.admin?).to be_truthy
  end
end
