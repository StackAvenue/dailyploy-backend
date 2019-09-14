defmodule DailyployWeb.TaskController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Schema.Task

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, %{"project_id" => project_id}) do
    tasks = TaskModel.list_tasks(project_id) |> Repo.preload([:user])

    render(conn, "index.json", tasks: tasks)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"project_id" => project_id, "task" => task_params}) do
    user = Guardian.Plug.current_resource(conn)

    task_params = Map.put(task_params, "project_id", project_id)
    task_params = Map.put(task_params, "user_id", user.id)

    case TaskModel.create_task(task_params) do
      {:ok, %Task{} = task} ->
        render(conn, "show.json", task: task |> Repo.preload([:user]))
      {:error, task} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: task.errors})
    end
  end
end
