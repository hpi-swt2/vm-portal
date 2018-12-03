# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OperationSystems', type: :request do
  describe 'GET /operation_systems' do
    it 'works! (now write some real specs)' do
      get operation_systems_path
      expect(response).to have_http_status(200)
    end
  end
end
