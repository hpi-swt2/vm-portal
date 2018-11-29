# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ServerController, type: :controller do
  describe 'GET #index' do
    before do
      double_api = double
      allow(double_api).to receive(:all_hosts).and_return [{ name: 'someHostMachine', connectionState: 'connected' },
                                                           { name: 'anotherHost', connectionState: 'not connected' }]

      allow(VmApi).to receive(:instance).and_return double_api
      allow(double_api).to receive(:connected?).and_return true

      double_flash = double
      allow(double_flash).to receive(:discard)
      allow_any_instance_of(ServerController).to receive(:flash).and_return(double_flash)
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'renders index page' do
      expect(get(:index)).to render_template('server/index')
    end

    it 'returns all hosts per default' do
      controller = ServerController.new
      controller.params = {}
      controller.index
      expect(controller.hosts.size).to be VmApi.instance.all_hosts.size
    end

    it 'returns online hosts if requested' do
      controller = ServerController.new
      controller.params = { up_hosts: 'true' }
      controller.index
      expect(controller.hosts).to satisfy('include online hosts') { |hosts| hosts.any? { |host| host[:connectionState] == 'connected' } }
      expect(controller.hosts).not_to satisfy('include offline hosts') { |hosts| hosts.any? { |host| host[:connectionState] != 'connected' } }
    end

    it 'returns offline hosts if requested' do
      controller = ServerController.new
      controller.params = { down_hosts: 'true' }
      controller.index
      expect(controller.hosts).to satisfy('include offline hosts') { |hosts| hosts.any? { |host| host[:connectionState] != 'connected' } }
      expect(controller.hosts).not_to satisfy('include online hosts') { |hosts| hosts.any? { |host| host[:connectionState] == 'connected' } }
    end
  end

  describe 'get #show' do
    before do
      double_api = double
      allow(double_api).to receive(:get_host).and_return(nil)
      allow(VmApi).to receive(:instance).and_return double_api
    end

    it 'returns http success' do
      get :show, params: { id: 1 }
      expect(response).to have_http_status(:success)
    end

    it 'renders show page' do
      expect(get(:show, params: { id: 1 })).to render_template('server/show')
    end
  end
end
