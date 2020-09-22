defmodule DailyployWeb.TimeTrackingController do
  use DailyployWeb, :controller
  alias Dailyploy.Repo
  alias Dailyploy.Helper.TimeTracking
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Helper.Firebase
  alias Dailyploy.Model.TimeTracking, as: TTModel
  import DailyployWeb.Validators.TimeTracking
  import DailyployWeb.Helpers

  plug :load_task when action in [:start_tracking, :logg_time]
  plug :load_tracked_task when action in [:stop_tracking]
  plug :load_time_tracked when action in [:edit_tracked_time, :delete]

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

  def delete(conn, params) do
    case conn.status do
      nil ->
        case TTModel.delete_time_track(conn.assigns.time_tracked) do
          {:ok, task_stopped} ->
            conn
            |> put_status(200)
            |> render("task_stopped.json", %{task_stopped: task_stopped})

          {:error, task_stopped} ->
            error = extract_changeset_error(task_stopped)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
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

  def logg_time(conn, params) do
    case conn.status do
      nil ->
        params = create_params(params)

        with {:ok, task_stopped} <- TTModel.create(params) do
          conn
          |> put_status(200)
          |> render("task_stopped.json", %{task_stopped: task_stopped})
        else
          {:error, message} ->
            conn
            |> put_status(400)
            |> json(%{errors: message})
        end

      404 ->
        conn
        |> send_error(404, "Task Not Found")
    end
  end

  defp create_params(params) do
    start_time = Timex.beginning_of_day(DateTime.utc_now())
    in_second = params["logged_time"] * 60 * 60
    end_time = DateTime.add(start_time, in_second, :second)

    params =
      Map.put_new(params, "start_time", start_time)
      |> Map.put_new("end_time", end_time)
      |> Map.put_new("duration", in_second)
      |> Map.put_new("time_log", true)
  end

  defp load_task(%{params: %{"task_id" => task_id}} = conn, _params) do
    {task_id, _} = Integer.parse(task_id)

    case TaskModel.get(task_id) do
      {:ok, task} ->
        # TimeTracking.toggle_task(task)
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
