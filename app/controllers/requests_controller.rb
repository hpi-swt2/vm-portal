# frozen_string_literal: true

class RequestsController < ApplicationController
  include OperatingSystemsHelper
  before_action :set_request, only: %i[show edit update destroy]
  before_action :authenticate_wimi

  # GET /requests
  # GET /requests.json
  def index
    @requests = Request.all
  end

  # GET /requests/1
  # GET /requests/1.json
  def show; end

  # GET /requests/new
  def new
    @request = Request.new
  end

  # GET /requests/1/edit
  def edit; end

  def notify_users(message)
    User.all.each do |each|
      each.notify_slack(message)
    end
  end

  def successfully_saved(format, request)
    notify_users("New VM request:\n" + request.description_text)
    format.html { redirect_to @request, notice: 'Request was successfully created.' }
    format.json { render :show, status: :created, location: request }
  end

  # POST /requests
  # POST /requests.json
  def create
    @request = Request.new(request_params)
    set_sudo_rights(@request)

    respond_to do |format|
      if @request.save
        successfully_saved(format, @request)
      else
        format.html { render :new }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  def notify_request_update(request)
    return if request.pending?

    if request.accepted?
      notify_users("Request:\n#{@request.description_text}\nhas been *accepted*!")
    elsif request.rejected?
      message = "Request:\n#{@request.description_text}\nhas been *rejected*!"
      message += request.rejection_information.empty? ? '' : "\nwith comment: #{request.rejection_information}"
      notify_users(message)
    end
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update
    respond_to do |format|
      if @request.update(request_params)
        notify_request_update(@request)
        format.html { redirect_to @request, notice: 'Request was successfully updated.' }
        format.json { render :show, status: :ok, location: @request }
      else
        format.html { render :edit }
        format.json { render json: @request.errors, status: :unprocessable_entity }
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

  def request_accept_button
    @request = Request.find(params[:request])
    @request.accept!
    if @request.save
      notify_request_update(@request)
      redirect_to new_vm_path(request: @request)
    else
      redirect_to request_path(@request)
    end
  end

  private

  def set_sudo_rights(request)
    sudo_users_for_request = request.users_assigned_to_requests.select { |uatq| request_params[:sudo_user_ids].include?(uatq.user_id.to_s) }

    sudo_users_for_request.each do |association|
      association.sudo = true
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_params
    params.require(:request).permit(:name, :cpu_cores, :ram_mb, :storage_mb, :operating_system, :comment, :rejection_information, :status, user_ids: [], sudo_user_ids: [])
  end
end
