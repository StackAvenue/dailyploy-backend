defmodule DailyployWeb.WorkspaceController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.Task, as: TaskModel

  plug Auth.Pipeline
  plug :put_view, DailyployWeb.TaskView when action in [:project_tasks]

  action_fallback DailyployWeb.FallbackController

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    workspaces = WorkspaceModel.all_user_workspaces(user)
    render(conn, "index.json", workspaces: workspaces)
  end

  def project_tasks(conn, %{"workspace_id" => workspace_id}) do
    tasks = TaskModel.list_workspace_tasks(workspace_id) |> Repo.preload([:user])
    render(conn, "index.json", tasks: tasks)
  end

end
