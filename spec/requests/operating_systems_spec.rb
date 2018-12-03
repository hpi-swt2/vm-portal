# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OperatingSystems', type: :request do
  describe 'GET /operating_systems' do
    it 'works! (now write some real specs)' do
      get operating_systems_path
      expect(response).to have_http_status(200)
    end
  end
end
