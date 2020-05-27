defmodule DailyployWeb.TaskStatusController do
  use DailyployWeb, :controller
  import Plug.Conn
  alias Dailyploy.Helper.TaskStatus
  import DailyployWeb.Validators.TaskStatus
  import DailyployWeb.Helpers

  plug DailyployWeb.Plug.TaskStatus when action in [:create, :show, :delete, :update]

  # def show(conn, %{"id" => id}) do
  #   case conn.status do
  #     nil ->
  #       {id, _} = Integer.parse(id)
  #       {:list, {:ok, task_category}} = {:list, TaskCategoryModel.get(id)}

  #       conn
  #       |> put_status(200)
  #       |> render("task_category.json", %{task_category: task_category})

  #     404 ->
  #       conn
  #       |> put_status(404)
  #       |> json(%{"Resource Not Found" => true})
  #   end
  # end

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

  # def update(conn, %{"workspace_id" => workspace_id, "name" => name, "id" => id} = params) do
  #   task_category = conn.assigns.task_category

  #   workspace_task_category =
  #     WorkspaceTaskCategoryModel.get_workspace_task_category_id(workspace_id, id)

  #   with false <- is_nil(workspace_task_category) do
  #     WorkspaceTaskCategoryModel.delete(workspace_task_category)

  #     case TaskCategoryModel.query_already_existing_category(name) do
  #       nil ->
  #         case TaskCategoryModel.create(params) do
  #           {:ok, task_category} ->
  #             conn
  #             |> put_status(200)
  #             |> render("task_category.json", %{task_category: task_category})

  #           {:error, errors} ->
  #             conn
  #             |> put_status(400)
  #             |> render("changeset_error.json", %{errors: errors.errors})
  #         end

  #       task_category ->
  #         params = %{task_category_id: task_category.id, workspace_id: workspace_id}

  #         case WorkspaceTaskCategoryModel.create(params) do
  #           {:ok, _params} ->
  #             conn
  #             |> put_status(200)
  #             |> render("task_category.json", %{task_category: task_category})

  #           {:error, errors} ->
  #             conn
  #             |> put_status(400)
  #             |> render("changeset_error.json", %{errors: errors.errors})
  #         end
  #     end
  #   else
  #     true ->
  #       conn
  #       |> put_status(404)
  #       |> json(%{"category_not_found" => true})
  #   end
  # end

  # def delete(conn, %{"workspace_id" => workspace_id, "id" => id}) do
  #   workspace_task_category =
  #     WorkspaceTaskCategoryModel.get_workspace_task_category_id(workspace_id, id)

  #   with false <- is_nil(workspace_task_category) do
  #     WorkspaceTaskCategoryModel.delete(workspace_task_category)

  #     conn
  #     |> put_status(200)
  #     |> json(%{"category_deleted" => true})
  #   else
  #     true ->
  #       conn
  #       |> put_status(404)
  #       |> json(%{"category_not_found" => true})
  #   end
  # end
end
