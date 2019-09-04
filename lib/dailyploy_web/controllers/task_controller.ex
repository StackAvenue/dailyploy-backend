defmodule DailyployWeb.TaskController do
  use DailyployWeb, :controller

  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Schema.Task

  action_fallback DailyployWeb.FallbackController

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, %{"project_id" => project_id}) do

    tasks = TaskModel.list_tasks(project_id)

    render(conn, "index.json", tasks: tasks)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"project_id" => project_id, "task" => task_params}) do
    task_params = Map.put(task_params, "project_id", project_id)

    case TaskModel.create_task(task_params) do
      {:ok, %Task{} = task} ->
        render(conn, "show.json", task: task)
      {:error, task} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: task.errors})
    end
  end
end
