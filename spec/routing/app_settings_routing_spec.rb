require "rails_helper"

RSpec.describe AppSettingsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/app_settings").to route_to("app_settings#index")
    end

    it "routes to #new" do
      expect(:get => "/app_settings/new").to route_to("app_settings#new")
    end

    it "routes to #show" do
      expect(:get => "/app_settings/1").to route_to("app_settings#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/app_settings/1/edit").to route_to("app_settings#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/app_settings").to route_to("app_settings#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/app_settings/1").to route_to("app_settings#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/app_settings/1").to route_to("app_settings#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/app_settings/1").to route_to("app_settings#destroy", :id => "1")
    end
  end
end
