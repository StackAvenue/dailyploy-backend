defmodule DailyployWeb.TaskStatusController do
  use DailyployWeb, :controller
  import Plug.Conn
  alias Dailyploy.Helper.TaskStatus
  import DailyployWeb.Validators.TaskStatus
  import DailyployWeb.Helpers

  plug DailyployWeb.Plug.TaskStatus when action in [:create, :show, :delete, :update]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, task_status}} = {:list, TaskStatus.get(id)}

        conn
        |> put_status(200)
        |> render("task_status.json", %{task_status: task_status})

      404 ->
        conn
        |> put_status(404)
        |> json(%{"Resource Not Found" => true})
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_task_status(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, task_status}} <- {:create, TaskStatus.create(data)} do
          conn
          |> put_status(200)
          |> render("task_status.json", %{task_status: task_status})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  # def index(conn, %{"workspace_id" => workspace_id}) do
  #   workspace_id = String.to_integer(workspace_id)
  #   {:ok, task_category} = WorkspaceModel.get(workspace_id)
  #   task_category = task_category |> Repo.preload(:task_categories)
  #   render(conn, "index.json", task_category: task_category)
  # end

  def update(conn, params) do
    case conn.status do
      nil ->
        case TaskStatus.update(conn.assigns.task_status, params) do
          {:ok, task_status} ->
            conn
            |> put_status(200)
            |> render("task_status.json", %{task_status: task_status})

          {:error, task_status} ->
            error = extract_changeset_error(task_status)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        case TaskStatus.delete(conn.assigns.task_status) do
          {:ok, task_status} ->
            conn
            |> put_status(200)
            |> render("task_status.json", %{task_status: task_status})

          {:error, task_status} ->
            error = extract_changeset_error(task_status)

            conn
            |> send_error(400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end
end
