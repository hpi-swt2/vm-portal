require 'rails_helper'

RSpec.describe OmniAuthCallbacksController, type: :controller do
  before do
    sign_in FactoryBot.create :user
  end
end
