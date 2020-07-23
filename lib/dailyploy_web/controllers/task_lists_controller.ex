defmodule DailyployWeb.TaskListsController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.TaskLists
  alias Dailyploy.Model.TaskLists, as: PTModel
  import DailyployWeb.Validators.TaskLists
  import DailyployWeb.Helpers

  plug :load_task_list when action in [:update, :delete, :show]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_project_task_list(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, project_task_list}} <- {:create, TaskLists.create(data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{project_task_list: project_task_list})
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

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}

        {:list, task_lists} =
          {:list, PTModel.get_all(data, [:workspace, :creator, :project], data.project_id)}

        conn
        |> put_status(200)
        |> render("index.json", %{task_lists: task_lists})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, _params) do
    case conn.status do
      nil ->
        conn
        |> put_status(200)
        |> render("show.json", %{project_task_list: conn.assigns.task_list})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        with {:update, {:ok, task_list}} <-
               {:update, PTModel.update(conn.assigns.task_list, params)} do
          conn
          |> put_status(200)
          |> render("show.json", %{project_task_list: task_list})
        else
          {:update, {:error, error}} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        with {:delete, {:ok, task_list}} <- {:delete, PTModel.delete(conn.assigns.task_list)} do
          conn
          |> put_status(200)
          |> render("show.json", %{project_task_list: task_list})
        else
          {:delete, {:error, error}} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_task_list(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case PTModel.get(id) do
      {:ok, task_list} ->
        assign(conn, :task_list, task_list)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
