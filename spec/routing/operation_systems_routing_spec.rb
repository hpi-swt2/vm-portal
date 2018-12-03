# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OperationSystemsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/operation_systems').to route_to('operation_systems#index')
    end

    it 'routes to #new' do
      expect(get: '/operation_systems/new').to route_to('operation_systems#new')
    end

    it 'routes to #show' do
      expect(get: '/operation_systems/1').to route_to('operation_systems#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/operation_systems/1/edit').to route_to('operation_systems#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/operation_systems').to route_to('operation_systems#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/operation_systems/1').to route_to('operation_systems#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/operation_systems/1').to route_to('operation_systems#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/operation_systems/1').to route_to('operation_systems#destroy', id: '1')
    end
  end
end
