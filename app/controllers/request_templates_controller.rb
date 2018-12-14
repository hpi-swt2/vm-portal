# frozen_string_literal: true

class RequestTemplatesController < ApplicationController
  before_action :set_request_template, only: %i[show edit update destroy]

  # GET /request_templates
  # GET /request_templates.json
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
  # POST /request_templates.json
  def create
    @request_template = RequestTemplate.new(request_template_params)

    respond_to do |format|
      if @request_template.save
        respond(format, 'Request template was successfully created.')
      else
        format.html { render :new }
        format.json { render json: @request_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /request_templates/1
  # PATCH/PUT /request_templates/1.json
  def update
    respond_to do |format|
      if @request_template.update(request_template_params)
        respond(format, 'Request template was successfully updated.')
      else
        format.html { render :edit }
        format.json { render json: @request_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /request_templates/1
  # DELETE /request_templates/1.json
  def destroy
    @request_template.destroy
    respond_to do |format|
      respond(format, 'Request template was successfully destroyed.')
    end
  end

  private

  def respond(format, notice)
    format.html { redirect_to request_templates_path, notice: notice }
    format.json { head :no_content }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_request_template
    @request_template = RequestTemplate.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def request_template_params
    params.require(:request_template).permit(:name, :cpu_cores, :ram_mb, :storage_mb, :operating_system)
  end
end
