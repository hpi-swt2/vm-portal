# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]
  before_action :authenticate_employee, only: %i[new create]
  before_action :authenticate_responsible_user, only: %i[edit update destroy]

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/1
  def show; end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # POST /projects
  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
      @project.responsible_users.each do |each|
        each.notify('Project created',
                    "The project #{@project.name} with you as the responsible has been created.",
                    url_for(controller: :projects, action: 'show', id: @project.id))
      end
    else
      render :new
    end
  end

  # GET /projects/1/edit
  def edit; end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to projects_path, notice: 'Project was successfully deleted.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])
  end

  def authenticate_responsible_user
    @project = Project.find(params[:id])
    redirect_to dashboard_path, alert: I18n.t('authorization.unauthorized') unless @project.responsible_users.include? current_user
  end

  def project_params
    p = params.require(:project).permit(:name, :description, responsible_user_ids: [])
    # Form returns :responsible_user_ids, a list of ids, turn them into user objects
    p.merge(responsible_users: User.where(id: p.delete(:responsible_user_ids)))
  end
end
