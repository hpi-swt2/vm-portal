# frozen_string_literal: true

class ServersController < ApplicationController
  @@resource_name = Server.model_name.human.titlecase

  before_action :set_server, only: %i[show edit update destroy]
  before_action :authenticate_employee, only: %i[show index]
  before_action :authenticate_admin, only: %i[new create edit update destroy]

  # GET /servers
  def index
    @servers = Server.all
  end

  # GET /servers/1
  def show; end

  # GET /servers/new
  def new
    @server = Server.new
  end

  # GET /servers/1/edit
  def edit; end

  # POST /servers
  def create
    @server = Server.new(server_params)
    if @server.save
      redirect_to @server, notice: 'Server was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /servers/1
  def update
    if @server.update(server_params)
      redirect_to @server, notice: 'Server was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /servers/1
  def destroy
    @server.destroy
    redirect_to servers_path, notice: 'Server was successfully deleted.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_server
    @server = Server.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def server_params
    # `installed_software: []` permits arrays
    params.require(:server).permit(:name, :cpu_cores, :ram_gb, :storage_gb, :ipv4_address,
                                   :ipv6_address, :mac_address, :fqdn, {installed_software: []},
                                   :model, :vendor, :description, :responsible_id, sudo_user_ids: [], user_ids: [])
    # Remove empty software form fields
    # https://api.rubyonrails.org/classes/ActionController/Parameters.html#method-i-each_pair
    params[:server].each { |k,v| v.reject!(&:blank?) if k.eql?('installed_software') }
  end
end
