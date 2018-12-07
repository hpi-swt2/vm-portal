require 'rails_helper'

RSpec.describe "RequestTemplates", type: :request do
  describe "GET /request_templates" do
    it "works! (now write some real specs)" do
      get request_templates_path
      expect(response).to have_http_status(200)
    end
  end
end
