# frozen_string_literal: true

class RequestsController < ApplicationController
  @@resource_name = Request.model_name.human.titlecase

  before_action :set_request, only: %i[show edit update push_to_git destroy reject]
  before_action :set_request_templates, only: %i[show new edit update create reject]
  before_action :authenticate_employee

  # GET /requests
  def index
    if current_user.admin?
      requests = Request.all
    else
      requests = Request.where(user: current_user)
    end
    @pending_requests = requests.pending
    @resolved_requests = requests.resolved
  end

  # GET /requests/1
  def show
    redirect_to edit_request_path(@request) if current_user.admin? && @request.pending?
  end

  # GET /requests/new
  def new
    @request = Request.new
  end

  # GET /requests/1/edit
  def edit
    redirect_to @request unless @request.pending?
  end

  # POST /requests
  def create
    @request = Request.new(request_params.merge(user: current_user))
    @request.assign_sudo_users(request_params[:sudo_user_ids])
    # check for validity first, before checking enough_resources?
    # this is neccessary to ensure that the request contains all information needed for enough_resources?
    if @request.valid? && enough_resources? && @request.save
      notify_users('New VM request', @request.description_text, @request.description_url(host_url))
      redirect_to requests_path, notice: t('flash.create.notice', resource: @@resource_name, model: @request.name)
    else
      render :new
    end
  end

  # PATCH/PUT /requests/1
  def update
    @request.assign_sudo_users(request_params[:sudo_user_ids])
    @request.accept!
    if @request.update(request_params)
      notify_request_update
      safe_create_vm_for @request
    else
      render :edit
    end
  end

  # PATCH /requests/reject/1
  def reject
    @request.reject!
    if @request.update(rejection_params)
      notify_request_update
      redirect_to requests_path, notice: "Request '#{@request.name}' rejected!"
    else
      render :edit
    end
  end

  # DELETE /requests/1
  def destroy
    if @request.destroy
      notice = t('flash.destroy.notice', resource: @@resource_name, model: @request.name)
    else
      alert = t('flash.destroy.alert', resource: @@resource_name, model: @request.name)
    end
    redirect_to requests_url, notice: notice, alert: alert
  end

  # Creates puppet files for request and pushes the created files into a git repository
  def push_to_git
    response = @request.push_to_git
    redirect_to requests_path, response
  end

  private

  def safe_create_vm_for(request)
    vm, warning = request.create_vm
    if vm
      redirect_to edit_config_path(vm.name), notice: 'VM was successfully created!'
    else
      redirect_to requests_path, alert: "Error while creating VM! #{warning || 'Please create it manually in vSphere'}"
    end
  rescue RbVmomi::Fault => fault
    redirect_to requests_path, alert: "Error while creating VM! #{fault.message}"
  end

  def host_url
    request.base_url
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.find(params[:id])
  end

  def set_request_templates
    @request_templates = RequestTemplate.all
  end

  def notify_users(title, message, link)
    ([@request.user] + @request.users + User.admin).uniq.each do |each|
      each.notify(title, message, link)
    end
  end

  def notify_request_update
    return if @request.pending?

    if @request.accepted?
      ([@request.user] + User.admin).uniq.each do |each|
        each.notify('VM request has been accepted', @request.description_text, @request.description_url(host_url))
      end
      @request.users.uniq.each do |each|
        rights = @request.sudo_users.include?(each) ? 'sudo access' : 'access'
        each.notify("You have #{rights} rights on a new VM", @request.description_text, @request.description_url(host_url))
      end
    elsif @request.rejected?
      message = @request.description_text
      message += @request.rejection_information.empty? ? '' : "\nwith comment: #{@request.rejection_information}"
      notify_users('VM request has been rejected', message, @request.description_url(host_url))
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # Modify parameters received from the request form
  def request_params
    if params[:request]
      # sudo_user_ids always contain one empty element which must be removed
      params[:request][:sudo_user_ids].reject!(&:blank?)
      # the user_ids must contain the ids of ALL users, sudo or not
      params[:request][:user_ids] ||= []
      params[:request][:user_ids] += params[:request][:sudo_user_ids] if params[:request][:sudo_user_ids]
    end

    params.require(:request).permit(:name, :cpu_cores, :ram_gb, :storage_gb, :operating_system,
                                    :port, :application_name, :description, :comment, :project_id, :port_forwarding,
                                    :rejection_information, responsible_user_ids: [],
                                    user_ids: [], sudo_user_ids: []).except(:template_id)
  end

  def rejection_params
    params.require(:request).permit(:rejection_information)
  end

  def puppet_node_script(request)
    request.generate_puppet_node_script
  end
  helper_method :puppet_node_script

  def puppet_name_script(request)
    request.generate_puppet_name_script
  end

  helper_method :puppet_name_script

  def enough_resources?
    hosts = VSphere::Host.all
    if hosts.empty?
      @request.errors[:base] << 'You cannot create a request right now. There are no hosts available!'
      return false
    end

    host_available = hosts.any? do |host|
      host.enough_resources?(@request.cpu_cores, @request.ram_gb, @request.storage_gb)
    end
    return true if host_available

    max_cpu_host = hosts.max_by(&:cpu_cores)
    max_ram_host = hosts.max_by(&:ram_gb)
    max_storage_host = hosts.max_by(&:free_storage_gb)

    max_cpu_host_msg = "cores: #{max_cpu_host.cpu_cores}, ram: #{max_cpu_host.ram_gb}GB, hdd: #{max_cpu_host.storage_gb}GB"
    max_ram_host_msg = "cores: #{max_ram_host.cpu_cores}, ram: #{max_ram_host.ram_gb}GB, hdd: #{max_ram_host.storage_gb}GB"
    max_storage_host_msg = "cores: #{max_storage_host.cpu_cores}, ram: #{max_storage_host.ram_gb}GB, hdd: #{max_storage_host.storage_gb}GB"

    error_message = "Requested VM resources are too high! Most Powerful Hosts are:\nMax CPU Cores Host(#{max_cpu_host_msg})\nMax RAM Host(#{max_ram_host_msg})\nMax HDD Host(#{max_storage_host_msg}) "
    @request.errors[:base] << error_message
    false
  end
end
