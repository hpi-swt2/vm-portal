require 'rails_helper'

RSpec.describe "Servers", type: :request do
  describe "GET /servers" do
    it "works! (now write some real specs)" do
      get servers_path
      expect(response).to have_http_status(200)
    end
  end
end
