defmodule DailyployWeb.TimeTrackingController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.TimeTracking
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Model.TimeTracking, as: TTModel
  import DailyployWeb.Validators.TimeTracking
  import DailyployWeb.Helpers

  plug :load_task when action in [:start_tracking]
  plug :load_tracked_task when action in [:stop_tracking]

  def start_tracking(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_running_time_tracking(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, task_running}} <- {:create, TimeTracking.start_running(data)} do
          conn
          |> put_status(200)
          |> render("task_running.json", %{task_running: task_running})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Task Not Found")
    end
  end

  def stop_tracking(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{task_tracked: task_tracked}} = conn
        changeset = verify_stop_time_tracking(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, task_stopped}} <-
               {:create, TimeTracking.stop_running(task_tracked, data)} do
          conn
          |> put_status(200)
          |> render("task_stopped.json", %{task_stopped: task_stopped})
        else
          {:extract, {:error, error}} ->
            conn
            |> put_status(422)
            |> json(%{error: error})

          {:create, {:error, message}} ->
            conn
            |> put_status(400)
            |> json(%{errors: message})
        end

      404 ->
        conn
        |> put_status(404)
        |> json(%{"Task Running" => false})
    end
  end

  defp load_task(%{params: %{"task_id" => task_id}} = conn, _params) do
    {task_id, _} = Integer.parse(task_id)

    case TaskModel.get(task_id) do
      {:ok, task} ->
        assign(conn, :task, task)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  defp load_tracked_task(%{params: %{"task_id" => task_id}} = conn, _params) do
    {task_id, _} = Integer.parse(task_id)

    case TTModel.get(task_id) do
      {:ok, task_tracked} ->
        assign(conn, :task_tracked, task_tracked)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end