defmodule DailyployWeb.TaskListTasksController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.TaskListTasks
  alias Dailyploy.Model.TaskListTasks, as: TLModel
  # alias Dailyploy.Model.UserStories, as: USModel
  import DailyployWeb.Validators.TaskListTasks
  alias Dailyploy.Helper.TaskListTasks, as: HTask
  import DailyployWeb.Helpers
  alias Dailyploy.Repo

  plug :load_task_list when action in [:update, :delete, :show, :move_task]

  def index(conn, params) do
    changeset = verify_index_params(params)

    case conn.status do
      nil ->
        {:extract, {:ok, data}} = {:extract, extract_changeset_data(changeset)}

        {:list, task_lists} =
          {:list,
           TLModel.get_all(
             data,
             [:owner, :category, :task_lists, :task_status, :checklist, :comments, :task],
             data.task_lists_id,
             params
           )}

        conn
        |> put_status(200)
        |> render("index.json", %{task_lists: task_lists})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_task_list(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, task}} <- {:create, TaskListTasks.create(data)},
             {:update, {:ok, task_list_tasks}} <- {:update, HTask.add_identifier(task)} do
          conn
          |> put_status(200)
          |> render("show.json", %{task_list_tasks: task_list_tasks})
        else
          {:extract, {:error, error}} ->
            send_error(conn, 400, error)

          {:create, {:error, message}} ->
            send_error(conn, 400, message)

          {:update, {:error, message}} ->
            send_error(conn, 400, message)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        with {:delete, {:ok, task_list_tasks}} <-
               {:delete, TLModel.delete(conn.assigns.task_list_tasks)} do
          conn
          |> put_status(200)
          |> render("show.json", %{
            task_list_tasks:
              task_list_tasks
              |> Dailyploy.Repo.preload([
                :owner,
                :category,
                :task_lists,
                :task_status,
                :comments,
                :checklist
              ])
          })
        else
          {:delete, {:error, error}} ->
            send_error(conn, 400, extract_changeset_error(error))
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        with {:update, {:ok, task_list_tasks}} <-
               {:update, TLModel.update(conn.assigns.task_list_tasks, params)} do
          conn
          |> put_status(200)
          |> render("show.json", %{
            task_list_tasks:
              task_list_tasks
              |> Dailyploy.Repo.preload([
                :owner,
                :category,
                :task_lists,
                :task_status,
                :comments,
                :checklist
              ])
          })
        else
          {:update, {:error, error}} ->
            send_error(conn, 400, extract_changeset_error(error))
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def move_task(conn, params) do
    case conn.status do
      nil ->
        with {:create, {:ok, _task}} <-
               {:create, TLModel.move_task(conn.assigns.task_list_tasks, params)} do
          conn
          |> put_status(200)
          |> render("show.json", %{
            task_list_tasks:
              conn.assigns.task_list_tasks
              |> Dailyploy.Repo.preload([
                :owner,
                :category,
                :task_lists,
                :task_status,
                :comments,
                :checklist
              ])
          })
        else
          {:create, {:error, error}} ->
            send_error(conn, 400, extract_changeset_error(error))
        end

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
        |> render("show.json", %{
          task_list_tasks:
            conn.assigns.task_list_tasks
            |> Dailyploy.Repo.preload([
              :owner,
              :category,
              :task_lists,
              :task_status,
              :comments,
              :checklist
            ])
        })

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_task_list(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case TLModel.get(id) do
      {:ok, task_list_tasks} ->
        assign(conn, :task_list_tasks, task_list_tasks)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end

  # defp load_task_list(%{params: %{"user_stories_id" => id}} = conn, _params) do
  #   {id, _} = Integer.parse(id)

  #   case USModel.get(id) do
  #     {:ok, user_stories} ->
  #       assign(conn, :user_stories, user_stories)

  #     {:error, _message} ->
  #       conn
  #       |> put_status(404)
  #   end
  # end
end
