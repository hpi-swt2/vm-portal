# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it "can be created using the User factory" do
    @user = FactoryBot.create(:user)
    expect(@user.email).to include '@'
  end
end
