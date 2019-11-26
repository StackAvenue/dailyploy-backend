defmodule DailyployWeb.ProjectController do
  use DailyployWeb, :controller
  alias Dailyploy.Repo
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Schema.Project
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Schema.Workspace

  plug Auth.Pipeline
  plug :load_workspace_by_user
  plug :load_user_project_in_workspace when action in [:show, :delete]

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, %{"workspace_id" => workspace_id}) do
    projects =
      ProjectModel.list_projects_in_workspace(workspace_id) |> Repo.preload([:members, :owner])

    render(conn, "index.json", projects: projects)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"workspace_id" => workspace_id, "project" => project_params}) do
    user = Guardian.Plug.current_resource(conn)

    project_params =
      project_params
      |> Map.put("workspace_id", workspace_id)
      |> Map.put("owner_id", user.id)

    case ProjectModel.create_project(project_params) do
      {:ok, %Project{} = project} ->
        render(conn, "show.json", project: project)

      {:error, project} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: project.errors})
    end
  end

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t()
  def show(conn, _) do
    project = ProjectModel.get_user_projects(conn.assigns.project)
    render(conn, "show.json", project: project)
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"id" => id, "project" => project_params}) do
    project = ProjectModel.get_project!(id)

    case ProjectModel.update_project(project, project_params) do
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

    case ProjectModel.delete_project(project) do
      {:ok, _project} ->
        send_resp(conn, 202, "Project Deleted successfully")

      _ ->
        conn
        |> put_status(422)

        render("error_in_deletion.json", %{})
    end
  end

  defp load_user_project_in_workspace(
         %{params: %{"workspace_id" => workspace_id, "id" => id}} = conn,
         _
       ) do
    user_id = Guardian.Plug.current_resource(conn).id

    case ProjectModel.load_user_project_in_workspace(%{
           workspace_id: workspace_id,
           user_id: user_id,
           project_id: id
         }) do
      %Project{} = project -> assign(conn, :project, project)
      _ -> send_resp(conn, 404, "Resource Not Found")
    end
  end

  defp load_workspace_by_user(%{params: %{"workspace_id" => id}} = conn, _) do
    case WorkspaceModel.get_workspace_by_user(%{
           user_id: Guardian.Plug.current_resource(conn).id,
           workspace_id: id
         }) do
      %Workspace{} = workspace ->
        assign(conn, :workspace, workspace)

      _ ->
        send_resp(conn, 404, "Resource Not Found")
    end
  end
end
