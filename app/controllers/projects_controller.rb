class ProjectsController < ApplicationController
  # GET /projects/new
  def new
    @project = Project.new
    @current_user = current_user
  end

  # POST /requests.json
  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to :dashboard
    else
      render :new, locals: {current_user: current_user}
    end
  end

  def project_params
    params.require(:project).permit(:name, :description, responsible_user_ids: [])
  end
end