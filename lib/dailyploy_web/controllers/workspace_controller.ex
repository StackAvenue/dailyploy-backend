defmodule DailyployWeb.WorkspaceController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.User, as: UserModel

  plug Auth.Pipeline
  plug :put_view, DailyployWeb.UserView when action in [:user_tasks]
  plug :put_view, DailyployWeb.TaskView when action in [:project_tasks]

  action_fallback DailyployWeb.FallbackController

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)

    workspace_admin_query = UserModel.get_admin_user_query()

    workspaces = WorkspaceModel.all_user_workspaces(user) |> Repo.preload([:company, users: workspace_admin_query])

    render(conn, "index.json", workspaces: workspaces)
  end

  def user_tasks(conn, %{"workspace_id" => workspace_id}) do
    users = UserModel.list_users(workspace_id) |> Repo.preload([:tasks])

    render(conn, "user_tasks_index.json", users: users)
  end

  def project_tasks(conn, %{"workspace_id" => workspace_id}) do
    tasks = TaskModel.list_workspace_tasks(workspace_id) |> Repo.preload([:user])
    render(conn, "index.json", tasks: tasks)
  end

end
