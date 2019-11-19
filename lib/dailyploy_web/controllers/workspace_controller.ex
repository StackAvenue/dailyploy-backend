defmodule DailyployWeb.WorkspaceController do
  use DailyployWeb, :controller

  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.User, as: UserModel

  alias Dailyploy.Schema.Task
  alias Dailyploy.Schema.Project

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

  def user_tasks(conn, %{"workspace_id" => workspace_id, "frequency" => frequency, "start_date" => start_date}) do
    {:ok, start_date} =
      start_date
        |> Date.from_iso8601

    end_date =
      case frequency do
        "daily" ->
          start_date
        "weekly" ->
          Date.add(start_date, 6)
        "monthly" ->
          days = Date.days_in_month(start_date)
          Date.add(start_date, days - 1)
      end

    query =
      from task in Task,
      join: project in Project,
      on: task.project_id == project.id,
      where: project.workspace_id == ^workspace_id and fragment("?::date", task.start_datetime) >= ^start_date and fragment("?::date", task.start_datetime) <= ^end_date

    users = UserModel.list_users(workspace_id) |> Repo.preload([tasks: {query, project: [:members]}])

    users = Enum.map(users, fn user ->
      date_formatted_tasks = user.tasks
      |> Enum.reduce(%{}, fn task, acc ->
        end_date = DateTime.to_date(task.end_datetime)

        DateTime.to_date(task.start_datetime)
          |> Date.range(end_date)
          |> Enum.reduce(acc, fn date, date_acc ->
            date_acc = Map.put_new(date_acc, Date.to_iso8601(date), [])
            tasks = Map.get(date_acc, Date.to_iso8601(date)) ++ [task]
            Map.put(date_acc, Date.to_iso8601(date), tasks)
          end)
      end)

      Map.put(user, :tasks, date_formatted_tasks)
    end)

    render(conn, "user_tasks_index.json", users: users)
  end

  def project_tasks(conn, %{"workspace_id" => workspace_id}) do
    tasks = TaskModel.list_workspace_tasks(workspace_id) |> Repo.preload([:owner, :members])
    render(conn, "index.json", tasks: tasks)
  end

end
