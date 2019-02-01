# frozen_string_literal: true

class RequestsController < ApplicationController
  include OperatingSystemsHelper
  include RequestsHelper
  before_action :set_request, only: %i[show edit update push_to_git destroy request_state_change]
  before_action :authenticate_employee
  before_action :authenticate_state_change, only: %i[request_change_state]

  # GET /requests
  # GET /requests.json
  def index
    @requests = current_user.admin? ? Request.all : Request.select { |r| r.user == current_user }
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
    redirect_to edit_request_path(@request) if current_user.admin? && @request.pending?
    @request_templates = RequestTemplate.all
  end

  # GET /requests/new
  def new
    @request = Request.new
    @request_templates = RequestTemplate.all
  end

  # GET /requests/1/edit
  def edit
    redirect_to @request unless @request.pending?
  end

  def notify_users(title, message)
    ([@request.user] + @request.users + User.admin).each do |each|
      each.notify(title, message)
    end
  end

  # POST /requests
  # POST /requests.json
  def create
    prepare_params

    @request = Request.new(request_params.merge(user: current_user))

    respond_to do |format|
      #if enough_resources
        if @request.save
          @request.assign_sudo_users(request_params[:sudo_user_ids][1..-1])
          successful_save(format)
        else
          unsuccessful_action(format, :new)
        end
     # else
     #   unsuccessful_action(format, :new)
      #end
    end
  end


  def enough_resources
    def get_num_cpu (host)
      host[:summary].hardware.numCpuCores
    end

    def get_ram_gb (host)
      host[:summary].hardware.memorySize.to_i / 1024**3
    end

    def get_storage_gb (host)
      host[:summary].host.datastore.sum{ |datastore|  datastore.summary.freeSpace }.to_i / 1024**3
    end


    hosts = VmApi.instance.all_hosts

    # get max host resources
    max_cpu_host = hosts[0]
    max_ram_host = hosts[0]
    max_storage_host = hosts[0]

    hosts.each do | host |
      # check if the host could handle the vm
      host_num_cpu = get_num_cpu(host)
      host_ram = get_ram_gb(host)
      host_free_hdd = get_storage_gb(host)
      puts host_num_cpu
      puts host_ram
      puts host_free_hdd
      puts request_params[:cpu_cores].to_i
      puts request_params[:ram_mb].to_i
      puts request_params[:storage_mb].to_i
      
      if request_params[:cpu_cores].to_i <= host_num_cpu and request_params[:ram_mb].to_i <= host_ram and request_params[:storage_mb].to_i <= host_free_hdd
        return true
      end

      # get hosts with max resources per category
      if host_num_cpu > get_num_cpu(max_cpu_host)
        max_cpu_host = host
      end

      if host_ram > get_ram_gb(max_ram_host)
        max_ram_host = host
      end

      if host_free_hdd > get_storage_gb(max_storage_host)
        max_storage_host = host
      end
    end

    max_cpu_host_msg = "cores: #{get_num_cpu(max_cpu_host)}, ram: #{get_ram_gb(max_cpu_host)}GB, hdd: #{get_storage_gb(max_cpu_host)}GB"
    max_ram_host_msg = "cores: #{get_num_cpu(max_ram_host)}, ram: #{get_ram_gb(max_ram_host)}GB, hdd: #{get_storage_gb(max_ram_host)}GB"
    max_storage_host_msg = "cores: #{get_num_cpu(max_storage_host)}, ram: #{get_ram_gb(max_storage_host)}GB, hdd: #{get_storage_gb(max_storage_host)}GB"

    error_message = "Requested VM resources are too high! Most Powerful Hosts are: Max Core Host(#{max_cpu_host_msg}) Max RAM Host(#{max_ram_host_msg}) Max HDD Host(#{max_storage_host_msg}) "
    @request.errors[:base] << error_message
    return false
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update
    respond_to do |format|
      prepare_params
      if @request.update(request_params)
        @request.accept!
        @request.save
        notify_request_update
        vm = @request.create_vm
        if vm
          format.html { redirect_to({ controller: :vms, action: 'edit_config', id: vm.name }, method: :get, notice: I18n.t('request.successfully_updated_and_vm_created')) }
          format.json { render status: :ok }
        else
          format.html { redirect_to requests_path, alert: 'VM could not be created, please create it manually in vSphere!' }
        end
      else
        unsuccessful_action format, :edit
      end
    end
  end

  def reject
    @request = Request.find params[:id]
    respond_to do |format|
      if @request&.update(rejection_params)
        @request.reject!
        @request.save
        notify_request_update
        format.html { redirect_to requests_path, notice: "Request '#{@request.name}' rejected!" }
        format.json { render status: :ok, action: :index }
      else
        unsuccessful_action format, :edit
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request.destroy
    respond_to do |format|
      format.html { redirect_to requests_url, notice: 'Request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Creates puppet files for request and pushes the created files into a git repository
  def push_to_git
    response = @request.push_to_git
    redirect_to requests_path, response
  end

  private

  def host_url
    request.base_url
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.find(params[:id])
  end

  def authenticate_state_change
    @request = Request.find(params[:id])
    authenticate_admin
    redirect_to @request, alert: I18n.t('request.unauthorized_state_change') if @request.user == current_user && !current_user.admin?
  end

  def notify_request_update
    return if @request.pending?

    if @request.accepted?
      notify_users('Request has been accepted', @request.description_text(host_url))
    elsif @request.rejected?
      message = @request.description_text host_url
      message += @request.rejection_information.empty? ? '' : "\nwith comment: #{@request.rejection_information}"
      notify_users('Request has been rejected', message)
    end
  end

  def successful_save(format)
    notify_users('New VM request', @request.description_text(host_url))
    format.html { redirect_to requests_path, notice: 'Request was successfully created.' }
    format.json { render :show, status: :created, location: @request }
  end

  def unsuccessful_action(format, method)
    @request_templates = RequestTemplate.all
    format.html { render method }
    format.json { render json: @request.errors, status: :unprocessable_entity }
  end

  # Storage and RAM are displayed in GB but internally stored in MB.
  def prepare_params
    params[:request][:name] = replace_whitespaces(params[:request][:name]) if params[:request][:name]
    params[:request][:ram_mb] = gb_to_mb(params[:request][:ram_mb].to_i) if params[:request][:ram_mb]
    params[:request][:storage_mb] = gb_to_mb(params[:request][:storage_mb].to_i) if params[:request][:storage_mb]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    params.require(:request).permit(:name, :cpu_cores, :ram_mb, :storage_mb, :operating_system,
                                    :port, :application_name, :description, :comment,
                                    :rejection_information, user_ids: [], sudo_user_ids: [])
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
end
