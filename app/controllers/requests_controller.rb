# frozen_string_literal: true

class RequestsController < ApplicationController
  include OperatingSystemsHelper
  include RequestsHelper
  before_action :set_request, only: %i[show edit update destroy request_state_change]
  before_action :authenticate_employee
  before_action :authenticate_state_change, only: %i[request_change_state]

  # GET /requests
  # GET /requests.json
  def index
    @requests = current_user.admin? ? Request.all : Request.select { |r| r.user == current_user }
  end

  # GET /requests/1
  # GET /requests/1.json
  def show; end

  # GET /requests/new
  def new
    @request = Request.new
    @request_templates = RequestTemplate.all
  end

  # GET /requests/1/edit
  def edit
    @request_templates = RequestTemplate.all
  end

  def notify_users(title, message)
    User.all.each do |each|
      each.notify(title, message)
    end
  end

  # POST /requests
  # POST /requests.json
  def create
    params[:request][:name] = replace_whitespaces(params[:request][:name])
    @request = Request.new(request_params.merge(user: current_user))

    respond_to do |format|
      if @request.save
        @request.assign_sudo_users(request_params[:sudo_user_ids][1..-1])
        successful_save(format)
      else
        unsuccessful_action(format, :new)
      end
    end
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update
    respond_to do |format|
      params[:request][:name] = replace_whitespaces(params[:request][:name])
      if @request.update(request_params)
        notify_request_update
        format.html { redirect_to @request, notice: 'Request was successfully updated.' }
        format.json { render :show, status: :ok, location: @request }
      else
        unsuccessful_action(format, :edit)
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

  def request_change_state
    if @request.update(request_params)
      notify_request_update
      redirect_to requests_path, notice: I18n.t('request.successfully_updated')
    else
      redirect_to @request, alert: @request.errors
    end
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
    redirect_to @request, alert: I18n.t('request.unauthorized_state_change') if @request.user == current_user
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

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    params.require(:request).permit(:name, :cpu_cores, :ram_mb, :storage_mb, :operating_system,
                                    :port, :application_name, :description, :comment,
                                    :rejection_information, :status, user_ids: [], sudo_user_ids: [])
  end
end
