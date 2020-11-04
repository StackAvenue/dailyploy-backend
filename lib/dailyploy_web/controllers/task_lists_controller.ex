defmodule DailyployWeb.TaskListsController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.TaskLists
  alias Dailyploy.Model.TaskLists, as: PTModel
  alias Dailyploy.Model.TaskListTasks, as: TLTModel
  import DailyployWeb.Validators.TaskLists
  import DailyployWeb.Helpers

  plug :load_task_list when action in [:update, :delete, :show, :summary]

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

  def summary(conn, params) do
    case conn.status do
      nil ->
        query = TLTModel.create_query(conn.assigns.task_list.id, params)
        task_list = PTModel.load_data(conn.assigns.task_list, query, params)
        summary = PTModel.summary(task_list)

        conn
        |> put_status(200)
        |> render("summary.json", %{summary: summary})

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
          {:list,
           PTModel.get_all(
             data,
             [
               :workspace,
               :creator,
               :project,
               :category,
               user_stories: [
                 :owner,
                 :task_status,
                 :roadmap_checklist,
                 task_lists_tasks: :comments
               ]
             ],
             data.project_id
           )}

        conn
        |> put_status(200)
        |> render("index.json", %{task_lists: task_lists})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def show(conn, params) do
    case conn.status do
      nil ->
        query = TLTModel.create_query(conn.assigns.task_list.id, params)
        task_list = PTModel.load_data(conn.assigns.task_list, query, params)

        conn
        |> put_status(200)
        |> render("show_filter.json", %{project_task_list: task_list})

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

  defp load_task_list(%{params: %{"task_lists_id" => id}} = conn, _params) do
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
