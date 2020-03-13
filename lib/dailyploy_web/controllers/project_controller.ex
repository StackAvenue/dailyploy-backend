defmodule DailyployWeb.ProjectController do
  use DailyployWeb, :controller
  alias Dailyploy.Repo
  alias Dailyploy.Model.Project, as: ProjectModel
  alias Dailyploy.Helper.Contact
  alias Dailyploy.Model.Contact, as: ContactModel
  alias Dailyploy.Schema.Project
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  import DailyployWeb.Validators.Contact
  import DailyployWeb.Helpers

  plug Auth.Pipeline
  plug :load_workspace_by_user
  plug :load_user_project_in_workspace when action in [:show]
  plug :check_user_project_in_workspace when action in [:delete]

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, params) do
    query_params = map_to_atom(params)

    projects =
      ProjectModel.list_projects_in_workspace(query_params) |> Repo.preload([:members, :owner])

    render(conn, "index.json", projects: projects)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"workspace_id" => workspace_id, "project" => project_params} = params) do
    user = Guardian.Plug.current_resource(conn)

    project_params =
      project_params
      |> Map.put("workspace_id", workspace_id)
      |> Map.put("owner_id", user.id)

    case ProjectModel.create_project(project_params) do
      {:ok, %Project{} = project} ->
        contacts =
          with true <- Map.has_key?(params["project"], "contacts") do
            add_contacts(params["project"]["contacts"], project)
          else
            false -> []
          end

        project = Repo.preload(project, :contacts)
        render(conn, "show_create.json", project: project)

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

  def delete(conn, %{"workspace_id" => workspace_id}) do
    project_ids = conn.query_params

    case ProjectModel.delete_project(project_ids, String.to_integer(workspace_id)) do
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

  defp check_user_project_in_workspace(
         %{params: %{"ids" => ids, "workspace_id" => workspace_id}} = conn,
         _params
       ) do
    user = Guardian.Plug.current_resource(conn)

    with {:list, {:ok, 1}} <- {:list, UserWorkspaceModel.return_role_id(user.id, workspace_id)} do
      ids =
        ids
        |> String.split(",")
        |> Enum.map(fn x -> String.to_integer(x) end)

      # projects = ProjectModel.list_projects()
      # project_id_list = []
      # project_ids = Enum.map(projects, fn project -> project.workspace_id == workspace_id 
      #   Enum.concat(project_id_list, [project.id])
      # end)
      Map.replace!(conn, :query_params, ids)
    else
      {:list, {:ok, _params}} ->
        send_resp(conn, 400, "User is not Admin")
    end
  end

  defp map_to_atom(params) do
    for {key, value} <- params, into: %{}, do: {String.to_atom(key), value}
  end

  defp add_contacts(contacts, project) do
    for contact <- contacts do
      case create_contact(contact, project) do
        {:ok, contact} -> contact
        {:error, message} -> message
      end
    end
  end

  defp create_contact(contact, project) do
    contact = Map.put_new(contact, "project_id", project.id)
    changeset = verify_contact(contact)

    with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
         {:create, {:ok, contact}} <- {:create, Contact.create_contact(data)} do
      {:ok, contact}
    else
      {:extract, {:error, error}} ->
        {:error, error}

      {:create, {:error, message}} ->
        {:error, message}
    end
  end
end
