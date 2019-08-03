defmodule DailyployWeb.TaskController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Schema.Task

  plug Auth.Pipeline
  plug :get_task_by_id when action in [:show, :update, :delete]
  plug :load_task_in_project
  plug :load_user_by_task

  def index(conn, _params) do
    tasks = TaskModel.list_tasks()
    render(conn, "index.json", tasks: tasks)
  end

  def create(conn, %{"task" => task_params}) do
    task_params = Map.put(task_params, "project", conn.assigns.project)

    case TaskModel.create_task(task_params) do
      {:ok, %Task{} = task} ->
        render(conn, "show.json", task: task)

      {:error, task} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: task.errors})
    end
  end

  def show(conn, _) do
    task = conn.assigns.task
    render(conn, "show.json", task: task)
  end

  def update(conn, %{"task" => params}) do
    task = conn.assigns.task

    case TaskModel.update_task(task, params) do
      {:ok, %Task{} = task} ->
        render(conn, "show.json", task: task)

      {:error, task} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: task.errors})
    end
  end

  def delete(conn, _) do
    task = conn.assigns.task

    with {:ok, _task} <- TaskModel.delete_task(task) do
      send_resp(conn, 200, "Task Deleted successfully")
    end
  end

  defp get_task_by_id(%{params: %{"id" => id}} = conn, _) do
    case TaskModel.get_task!(id) do
      %Task{} = task ->
        assign(conn, :task, task)

      _ ->
        send_resp(conn, 404, "Not Found")
    end
  end

  defp load_task_in_project(%{params: %{"project_id" => project_id, "id" => task_id}} = conn, _) do
    case TaskModel.get_task_in_project!(%{project_id: project_id, task_id: task_id}) do
      %Task{} = task ->
        assign(conn, :task, task)

      _ ->
        send_resp(conn, 404, "Not Found")
    end
  end

  defp load_user_by_task(%{params: %{"task_id" => id}} = conn, _) do
    case TaskModel.get_user_by_task!(%{
           user_id: Guardian.Plug.current_resource(conn).id,
           task_id: id
         }) do
      %Task{} = task ->
        assign(conn, :task, task)

      _ ->
        send_resp(conn, 404, "Not Found")
    end
  end
end
