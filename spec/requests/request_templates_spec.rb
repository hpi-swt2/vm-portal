# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RequestTemplates', type: :request do
  before do
    sign_in FactoryBot.create :user
  end

  describe 'GET /request_templates' do
    it 'works! (now write some real specs)' do
      get request_templates_path
      expect(response).to have_http_status(200)
    end
  end
end
