# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :authenticate_employee, only: %i[new create]
  before_action :authenticate_responsible_user, only: %i[edit update destroy]

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/1
  def show
    @project = Project.find(params[:id])
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # POST /requests
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

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: 'Project was successfully deleted.'
  end

  private

  def authenticate_responsible_user
    @project = Project.find(params[:id])
    redirect_to dashboard_path, alert: I18n.t('authorization.unauthorized') unless @project.responsible_users.include? current_user
  end

  def project_params
    p = params.require(:project).permit(:name, :description, responsible_users_ids: [])
    # The projects form returns a list of ids of responsible_users, turn them into user objects
    responsible_users = p.delete(:responsible_users_ids).map { |id| User.find_by_id(id) }.reject(&:nil?)
    p.merge(responsible_users: responsible_users)
  end
end
