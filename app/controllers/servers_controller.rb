# frozen_string_literal: true

class ServersController < ApplicationController
  @@resource_name = Server.model_name.human.titlecase

  before_action :set_server, only: %i[show edit update destroy]
  before_action :authenticate_employee, only: %i[show index]
  before_action :authenticate_admin, only: %i[new create edit update destroy]
  # GET /servers
  # GET /servers.json
  def index
    @servers = Server.all
  end

  # GET /servers/1
  # GET /servers/1.json
  def show; end

  # GET /servers/new
  def new
    @server = Server.new
  end

  # GET /servers/1/edit
  def edit; end

  # POST /servers
  # POST /servers.json
  def create
    # parse software fields from the post parameters into the server_params
    software = []

    params.each do |key, value|
      key_matcher = /software\d+/
      software << value if key_matcher.match?(key)
    end

    # merge server_params [and software information
    server_params[:installed_software] = software

    server_params.permit(
      :name,
      :cpu_cores,
      :ram_gb,
      :storage_gb,
      :ipv4_address,
      :ipv6_address,
      :mac_address,
      :fqdn,
      :installed_software,
      :vendor,
      :model,
      :responsible_id,
      :description
    )

    # create new Server object
    setNewServerObject

    respond_to do |format|
      if @server.save
        format.html { redirect_to @server, notice: t('flash.create.notice', resource: @@resource_name, model: @server.name) }
        format.json { render :show, status: :created, location: @server }
      else
        format.html { render :new }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  def setNewServerObject
    @server = Server.new(
      name: server_params[:name],
      cpu_cores: server_params[:cpu_cores],
      ram_gb: server_params[:ram_gb],
      storage_gb: server_params[:storage_gb],
      mac_address: server_params[:mac_address],
      fqdn: server_params[:fqdn],
      ipv4_address: server_params[:ipv4_address],
      ipv6_address: server_params[:ipv6_address],
      installed_software: server_params[:installed_software],
      vendor: server_params[:vendor],
      model: server_params[:model],
      description: server_params[:description],
      responsible_id: server_params[:responsible]
    )
  end

  # PATCH/PUT /servers/1
  # PATCH/PUT /servers/1.json
  def update
    respond_to do |format|
      if @server.update(server_params.permit(
                          :name,
                          :cpu_cores,
                          :ram_gb,
                          :storage_gb,
                          :ipv4_address,
                          :ipv6_address,
                          :mac_address,
                          :fqdn,
                          :installed_software,
                          :model,
                          :vendor,
                          :description,
                          :responsible_id
                        ))
        format.html { redirect_to @server, notice: t('flash.update.notice', resource: @@resource_name, model: @server.name) }
        format.json { render :show, status: :ok, location: @server }
      else
        format.html { render :edit }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /servers/1
  # DELETE /servers/1.json
  def destroy
    @server.destroy
    respond_to do |format|
      format.html { redirect_to servers_path, notice: t('flash.destroy.notice', resource: @@resource_name, model: @server.name) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_server
    @server = Server.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def server_params
    params.fetch(:server, {})
  end
end
