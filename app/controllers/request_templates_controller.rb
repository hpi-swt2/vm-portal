# frozen_string_literal: true

class RequestTemplatesController < ApplicationController
  before_action :set_request_template, only: %i[show edit update destroy]
  before_action :authenticate_admin

  # GET /request_templates
  def index
    @request_templates = RequestTemplate.all
  end

  # GET /request_templates/new
  def new
    @request_template = RequestTemplate.new
  end

  # GET /request_templates/1/edit
  def edit; end

  # POST /request_templates
  def create
    @request_template = RequestTemplate.new(request_template_params)
    if @request_template.save
      redirect_to request_templates_path, notice: 'Request template was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /request_templates/1
  def update
    if @request_template.update(request_template_params)
      redirect_to request_templates_path, notice:'Request template was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /request_templates/1
  def destroy
    @request_template.destroy
    redirect_to request_templates_path, notice: 'Request template was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_request_template
    @request_template = RequestTemplate.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_template_params
    params.require(:request_template).permit(:name, :cpu_cores, :ram_gb, :storage_gb, :operating_system)
  end
end
