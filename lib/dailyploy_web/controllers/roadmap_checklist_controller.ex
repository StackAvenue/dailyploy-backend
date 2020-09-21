defmodule DailyployWeb.RoadmapChecklistController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.RoadmapChecklist
  alias Dailyploy.Model.RoadmapChecklist, as: RCModel
  import DailyployWeb.Validators.RoadmapChecklist
  import DailyployWeb.Helpers

  plug DailyployWeb.Plug.TaskLists
  plug :load_checklist when action in [:update, :delete]

  def create(conn, params) do
    case conn.status do
      nil ->
        changeset = verify_checklist(params)

        with {:extract, {:ok, data}} <- {:extract, extract_changeset_data(changeset)},
             {:create, {:ok, checklist}} <- {:create, RoadmapChecklist.create(data)} do
          conn
          |> put_status(200)
          |> render("show.json", %{checklist: checklist})
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

        {:list, checklists} =
          {:list, RoadmapChecklist.get_all(data, [], data.task_lists_id, data.user_stories_id)}

        conn
        |> put_status(200)
        |> render("index.json", %{checklists: checklists})

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        with {:update, {:ok, checklist}} <-
               {:update, RoadmapChecklist.update(conn.assigns.checklist, params)} do
          conn
          |> put_status(200)
          |> render("show.json", %{checklist: checklist})
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
        with {:delete, {:ok, checklist}} <-
               {:delete, RoadmapChecklist.delete(conn.assigns.checklist)} do
          conn
          |> put_status(200)
          |> render("show.json", %{checklist: checklist})
        else
          {:delete, {:error, error}} ->
            send_error(conn, 400, error)
        end

      404 ->
        conn
        |> send_error(404, "Resource Not Found")
    end
  end

  defp load_checklist(%{params: %{"id" => id}} = conn, _params) do
    {id, _} = Integer.parse(id)

    case RCModel.get(id) do
      {:ok, checklist} ->
        assign(conn, :checklist, checklist)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
