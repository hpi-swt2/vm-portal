# frozen_string_literal: true

class OperationSystemsController < ApplicationController
  before_action :set_operation_system, only: %i[show edit update destroy]

  # GET /operation_systems
  # GET /operation_systems.json
  def index
    @operation_systems = OperationSystem.all
  end

  # GET /operation_systems/1
  # GET /operation_systems/1.json
  def show; end

  # GET /operation_systems/new
  def new
    @operation_system = OperationSystem.new
  end

  # GET /operation_systems/1/edit
  def edit; end

  # POST /operation_systems
  # POST /operation_systems.json
  def create
    @operation_system = OperationSystem.new(operation_system_params)

    respond_to do |format|
      if @operation_system.save
        format.html { redirect_to @operation_system, notice: 'Operation system was successfully created.' }
        format.json { render :show, status: :created, location: @operation_system }
      else
        format.html { render :new }
        format.json { render json: @operation_system.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /operation_systems/1
  # PATCH/PUT /operation_systems/1.json
  def update
    respond_to do |format|
      if @operation_system.update(operation_system_params)
        format.html { redirect_to @operation_system, notice: 'Operation system was successfully updated.' }
        format.json { render :show, status: :ok, location: @operation_system }
      else
        format.html { render :edit }
        format.json { render json: @operation_system.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /operation_systems/1
  # DELETE /operation_systems/1.json
  def destroy
    @operation_system.destroy
    respond_to do |format|
      format.html { redirect_to operation_systems_url, notice: 'Operation system was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_operation_system
    @operation_system = OperationSystem.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def operation_system_params
    params.require(:operation_system).permit(:name)
  end
end
