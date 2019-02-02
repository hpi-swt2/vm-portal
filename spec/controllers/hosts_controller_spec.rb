# frozen_string_literal: true

require 'rails_helper'
require './spec/api/v_sphere_api_mocker'
RSpec.describe HostsController, type: :controller do
  # Authenticate an user
  before do
    sign_in current_user
  end

  let(:host) do
    v_sphere_host_mock("someHost")
  end

  let(:cluster) do
    # associate vm2 with the user
    v_sphere_cluster_mock("someCluster", [:host])
  end

  describe 'GET #index' do
    before do
      allow(VSphere::Host).to receive(:all).and_return nil
      get :index
    end

    context 'when the current user is an admin' do
      let(:current_user) { FactoryBot.create :admin }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'renders index page' do
        expect(response).to render_template('hosts/index')
      end
    end

    context 'when the current user is not an admin' do
      let(:current_user) { FactoryBot.create :user }

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'get #show' do
    before do
      allow(VSphere::Host).to receive(:all).and_return [host]
      allow(VSphere::Connection).to receive(:instance).and_return v_sphere_connection_mock(clusters: [:cluster])
    end

    context 'when the current user is an admin' do
      let(:current_user) { FactoryBot.create :admin }

      context 'when there is an host' do
        before do
          get :show, params: { id:  host.name }
        end

        it 'returns http success or timeout or not found' do
          expect(response).to have_http_status(:success).or have_http_status(408).or have_http_status(:not_found)
        end

        it 'renders show page' do
          expect(response).to render_template('hosts/show')
        end
      end

      context 'when there is no host' do
        before do
          get :show, params: { id: 'someHostNotThere' }
        end

        it 'returns http status not found when no host found' do
          expect(response).to have_http_status(:not_found)
        end

        it 'renders not found page when no host found' do
          expect(response).to render_template('errors/not_found')
        end
      end
    end

    context 'when the current user is not an admin' do
      let(:current_user) { FactoryBot.create :user }

      before do
        get(:show, params: { id: host.name })
      end

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
