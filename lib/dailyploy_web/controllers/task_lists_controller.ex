defmodule DailyployWeb.TaskListsController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.TaskLists
  alias Dailyploy.Model.TaskLists, as: TLModel
  import DailyployWeb.Validators.TaskLists
  import DailyployWeb.Helpers

  plug :load_task_list when action in [:update, :delete, :show]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_task_list(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, task_lists}} <- {:create, TaskLists.create(data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{task_lists: task_lists})
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

  defp load_task_list(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case TLModel.get(id) do
      {:ok, project_task_list} ->
        assign(conn, :project_task_list, project_task_list)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end