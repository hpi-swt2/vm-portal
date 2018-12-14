# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestTemplatesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/vms/request_templates').to route_to('request_templates#index')
    end

    it 'routes to #new' do
      expect(get: '/vms/request_templates/new').to route_to('request_templates#new')
    end

    it 'routes to #edit' do
      expect(get: '/vms/request_templates/1/edit').to route_to('request_templates#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/vms/request_templates').to route_to('request_templates#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/vms/request_templates/1').to route_to('request_templates#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/vms/request_templates/1').to route_to('request_templates#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/vms/request_templates/1').to route_to('request_templates#destroy', id: '1')
    end
  end
end
