defmodule DailyployWeb.Plug.TaskStatus do
  import Plug.Conn
  alias Dailyploy.Model.TaskStatus, as: TSModel
  alias Dailyploy.Model.Project, as: PModel
  def init(default), do: default

  def call(%{params: %{"id" => id}} = conn, _params) do
    load_task_status(conn, id)
  end

  def call(
        %{params: %{"project_id" => project_id, "workspace_id" => workspace_id}} = conn,
        _params
      ) do
    load_project_workspace(conn, project_id, workspace_id)
  end

  def load_task_status(conn, id) do
    {id, _} = Integer.parse(id)

    case TSModel.get(id) do
      {:ok, task_status} ->
        assign(conn, :task_status, task_status)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  def load_project_workspace(conn, project_id, workspace_id) do
    {project_id, _} = Integer.parse(project_id)
    {workspace_id, _} = Integer.parse(workspace_id)

    case PModel.get(project_id) do
      {:ok, project} ->
        case project.workspace_id == workspace_id do
          true ->
            assign(conn, :project, project)

          false ->
            conn
            |> put_status(404)
        end

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
