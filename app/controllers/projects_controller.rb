# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :authenticate_employee

  def index
    @projects = Project.all
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

  def project_params
    params.require(:project).permit(:name, :description, responsible_user_ids: [])
  end
end
