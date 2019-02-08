# frozen_string_literal: true

class HostsController < ApplicationController
  attr_reader :hosts
  before_action :authenticate_admin

  def index
    @hosts = VSphere::Host.all
  end

  def new; end

  def show
    @host = VSphere::Host.get_host(params[:id])
    render(template: 'errors/not_found', status: :not_found) if @host.nil?
  end
end
