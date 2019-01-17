# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :authenticate_employee, only: %i[new create]

  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])
  end

  # GET /projects/new
  def new
    @project = Project.new
    @current_user = current_user
  end

  # POST /requests.json
  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to action: :index
    else
      render :new, locals: { current_user: current_user }
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  private

  def project_params
    params.require(:project).permit(:name, :description, responsible_user_ids: [])
  end
end
