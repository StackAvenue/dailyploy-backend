defmodule DailyployWeb.ProjectController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Schema.Project
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Schema.Workspace

  plug Auth.Pipeline
  plug :load_workspace_by_user
  plug :load_user_project_in_workspace when action in [:show, :update, :delete]

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, _params) do
    projects =
      ProjectModel.list_user_projects_in_workspace(%{
        workspace_id: conn.assigns.workspace.id,
        user_id: Guardian.Plug.current_resource(conn).id
      })

    render(conn, "index.json", projects: projects)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"project" => project_params}) do
    project_params = add_workspace_and_user_in_project_params(project_params, conn)

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
    render(conn, "show.json", project: conn.assigns.project)
  end

  @spec update(Plug.Conn.t(), map) :: Plug.Conn.t()
  def update(conn, %{"project" => project_params}) do
    project = ProjectModel.get_project!(conn.assigns.project.id, [:users, :workspace])

    project_params =
      add_workspace_and_user_in_project_params_for_update(project_params, project, conn)

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

  defp add_workspace_and_user_in_project_params(project_params, conn) do
    project_params = Map.put(project_params, "workspace", conn.assigns.workspace)
    Map.put(project_params, "users", [Guardian.Plug.current_resource(conn)])
  end

  def add_workspace_and_user_in_project_params_for_update(project_params, project, conn) do
    project_params = Map.put(project_params, "workspace", conn.assigns.workspace)
    Map.put(project_params, "users", project.users)
  end
end
