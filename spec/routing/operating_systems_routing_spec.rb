# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OperatingSystemsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/vms/requests/operating_systems').to route_to('operating_systems#index')
    end

    it 'routes to #new' do
      expect(get: '/vms/requests/operating_systems/new').to route_to('operating_systems#new')
    end

    it 'routes to #edit' do
      expect(get: '/vms/requests/operating_systems/1/edit').to route_to('operating_systems#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/vms/requests/operating_systems').to route_to('operating_systems#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/vms/requests/operating_systems/1').to route_to('operating_systems#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/vms/requests/operating_systems/1').to route_to('operating_systems#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/vms/requests/operating_systems/1').to route_to('operating_systems#destroy', id: '1')
    end
  end
end
