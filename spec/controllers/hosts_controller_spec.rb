# frozen_string_literal: true

require 'rails_helper'
RSpec.describe HostsController, type: :controller do
  # Authenticate an user
  before do
    sign_in current_user
  end

  describe 'GET #index' do
    before do
      allow(VSphere::Host).to receive(:all).and_return nil
    end

    context 'when the current user is an admin' do
      let(:current_user) { FactoryBot.create :admin }
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders index page' do
        expect(get(:index)).to render_template('hosts/index')
      end
    end

    context 'current user is not an admin' do
      let(:current_user) { FactoryBot.create :user }

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'notifies about missing rights' do
        should set_flash.now[:alert].to('You do not have the necessary rights to perform this action.')
      end
    end
  end

  describe 'get #show' do
    let(:double_api) do
      double
    end

    before do
      allow(VmApi).to receive(:instance).and_return double_api
    end
    context 'when the current user is an admin' do
      let(:current_user) { FactoryBot.create :admin }

      it 'returns http success or timeout or not found' do
        allow(double_api).to receive(:get_host).and_return({})
        get :show, params: { id: 1 }
        expect(response).to have_http_status(:success).or have_http_status(408).or have_http_status(:not_found)
      end

      it 'renders show page' do
        allow(double_api).to receive(:get_host).and_return({})
        expect(get(:show, params: { id: 1 })).to render_template('hosts/show')
      end

      it 'returns http status not found when no host found' do
        allow(double_api).to receive(:get_host).and_return(nil)
        get :show, params: { id: 5 }
        expect(response).to have_http_status(:not_found)
      end

      it 'renders not found page when no host found' do
        allow(double_api).to receive(:get_host).and_return(nil)
        expect(get(:show, params: { id: 1 })).to render_template('errors/not_found')
      end
    end

    context 'current user is not an admin' do
      let(:current_user) { FactoryBot.create :user }

      it 'returns http redirect' do
        expect(response).to have_http_status(:redirect)
      end

      it 'notifies about missing rights' do
        should set_flash.now[:alert].to('You do not have the necessary rights to perform this action.')
      end
    end
  end
end
