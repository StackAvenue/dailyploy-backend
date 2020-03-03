defmodule DailyployWeb.TimeTrackingController do
  use DailyployWeb, :controller
  alias Dailyploy.Repo
  alias Dailyploy.Helper.TimeTracking
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Helper.Firebase
  alias Dailyploy.Model.TimeTracking, as: TTModel
  import DailyployWeb.Validators.TimeTracking
  import DailyployWeb.Helpers

  plug :load_task when action in [:start_tracking]
  plug :load_tracked_task when action in [:stop_tracking]
  plug :load_time_tracked when action in [:edit_tracked_time]

  def start_tracking(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_running_time_tracking(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, task_running}} <- {:create, TimeTracking.start_running(data)} do
          Firebase.insert_operation(
            Jason.encode(task_running),
            "task_status/#{(conn.assigns.task |> Repo.preload(:project)).project.workspace_id}/#{
              task_running.task_id
            }"
          )

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
          {:ok, task} = TaskModel.get(task_tracked.task_id)

          Firebase.insert_operation(
            Jason.encode(task_stopped),
            "task_status/#{(task |> Repo.preload(:project)).project.workspace_id}/#{
              task_stopped.task_id
            }"
          )

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

  def edit_tracked_time(conn, params) do
    case conn.status do
      404 ->
        conn
        |> put_status(404)
        |> json(%{"Time Tracked Found" => false})

      nil ->
        %{assigns: %{time_tracked: time_tracked}} = conn

        with {:ok, task_stopped} <- TTModel.update_tracked_time(time_tracked, params) do
          conn
          |> put_status(200)
          |> render("task_stopped.json", %{task_stopped: task_stopped})
        else
          {:error, message} ->
            conn
            |> put_status(400)
            |> json(%{errors: message})
        end
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

  defp load_time_tracked(%{params: %{"id" => id, "task_id" => task_id}} = conn, _params) do
    {id, _} = Integer.parse(id)
    {task_id, _} = Integer.parse(task_id)

    case TTModel.get_time_tracked(id, task_id) do
      {:ok, time_tracked} ->
        assign(conn, :time_tracked, time_tracked)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
