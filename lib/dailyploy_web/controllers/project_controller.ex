defmodule DailyployWeb.ProjectController do
  use DailyployWeb, :controller

  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Schema.Project

  action_fallback DailyployWeb.FallbackController

  def index(conn, _params) do
    projects = ProjectModel.list_projects()
    render(conn, "index.json", projects: projects)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"project" => project_params}) do
    with {:ok, %Project{} = project} <- ProjectModel.create_project(project_params) do
      render(conn, "show.json", project: project)
    end
  end

  def show(conn, %{"id" => id}) do
    project = ProjectModel.get_project!(id)
    render(conn, "show.json", project: project)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = ProjectModel.get_project!(id)

    with {:ok, %Project{} = project} <- ProjectModel.update_project(project, project_params) do
      render(conn, "show.json", project: project)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = ProjectModel.get_project!(id)

    with {:ok, %Project{}} <- ProjectModel.delete_project(project) do
      send_resp(conn, :no_content, "")
    end
  end
end
