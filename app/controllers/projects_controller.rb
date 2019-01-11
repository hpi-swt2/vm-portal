class ProjectsController < ApplicationController
  # GET /projects/new
  def new
    @project = Project.new
  end

  # POST /requests.json
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to :dashboard
    else
      render :new
    end
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end