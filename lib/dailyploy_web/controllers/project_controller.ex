defmodule DailyployWeb.ProjectController do
  use DailyployWeb, :controller

  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Schema.Project

  action_fallback DailyployWeb.FallbackController
  plug :get_project_by_id when action in [:show, :update, :delete]

  def index(conn, _params) do
    projects = ProjectModel.list_projects()
    render(conn, "index.json", projects: projects)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"project" => project_params}) do
    case ProjectModel.create_project(project_params) do
      {:ok, %Project{} = project} ->
        render(conn, "show.json", project: project)
      {:error, project} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: project.errors})
    end
  end

  def show(conn, _) do
    project = conn.assigns.project
    render(conn, "show.json", project: project)
  end

  def update(conn, %{"project" => params}) do
    project = conn.assigns.project
    case ProjectModel.update_project(project, params) do
      {:ok, %Project{} = project} ->
        render(conn, "show.json", project: project)
      {:error, project} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: project.errors})
    end
  end

  def delete(conn, _) do
    project = conn.assigns.project
    with {:ok, project} <- ProjectModel.delete_project(project) do
      send_resp(conn, 200, "Project Deleted successfully")
    end
  end

  defp get_project_by_id(%{params: %{"id" => id}} = conn, _) do
    case ProjectModel.get_project!(id) do
      %Project{} = project ->
        assign(conn, :project, project)
      _ -> send_resp(conn, 404, "Not Found")
    end
  end
end
