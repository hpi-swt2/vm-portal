# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppSettingsController, type: :routing do
  describe 'routing' do
    it 'routes to #edit' do
      expect(get: '/app_settings/1/edit').to route_to('app_settings#edit', id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: '/app_settings/1').to route_to('app_settings#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/app_settings/1').to route_to('app_settings#update', id: '1')
    end
  end
end
