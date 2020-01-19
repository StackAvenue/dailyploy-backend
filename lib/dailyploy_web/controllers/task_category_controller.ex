defmodule DailyployWeb.TaskCategoryController do
  use DailyployWeb, :controller
  import Plug.Conn
  # alias Dailyploy.Schema.TaskCategory
  alias Dailyploy.Model.TaskCategory, as: TaskCategoryModel
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.WorkspaceTaskCategory, as: WorkspaceTaskCategoryModel

  alias Dailyploy.Repo

  plug :load_category when action in [:show, :delete, :update]

  def show(conn, %{"id" => id}) do
    case conn.status do
      nil ->
        {id, _} = Integer.parse(id)
        {:list, {:ok, task_category}} = {:list, TaskCategoryModel.get(id)}

        conn
        |> put_status(200)
        |> render("task_category.json", %{task_category: task_category})

      404 ->
        conn
        |> put_status(404)
        |> json(%{"Resource Not Found" => true})
    end
  end

  def create(conn, %{"name" => name, "workspace_id" => workspace_id} = attrs) do
    case TaskCategoryModel.query_already_existing_category(name) do
      nil ->
        case TaskCategoryModel.create(attrs) do
          {:ok, task_category} ->
            conn
            |> put_status(200)
            |> render("task_category.json", %{task_category: task_category})

          {:error, errors} ->
            conn
            |> put_status(400)
            |> render("changeset_error.json", %{errors: errors.errors})
        end

      task_category ->
        params = %{task_category_id: task_category.id, workspace_id: workspace_id}

        case WorkspaceTaskCategoryModel.create(params) do
          {:ok, _params} ->
            conn
            |> put_status(200)
            |> render("task_category.json", %{task_category: task_category})

          {:error, errors} ->
            conn
            |> put_status(400)
            |> render("changeset_error.json", %{errors: errors.errors})
        end
    end
  end

  def index(conn, %{"workspace_id" => workspace_id}) do
    workspace_id = String.to_integer(workspace_id)
    {:ok, task_category} = WorkspaceModel.get(workspace_id)
    task_category = task_category |> Repo.preload(:task_categories)
    render(conn, "index.json", task_category: task_category)
  end

  def update(conn, %{"workspace_id" => workspace_id, "name" => name, "id" => id} = params) do
    task_category = conn.assigns.task_category

    workspace_task_category =
      WorkspaceTaskCategoryModel.get_workspace_task_category_id(workspace_id, id)

    with false <- is_nil(workspace_task_category) do
      WorkspaceTaskCategoryModel.delete(workspace_task_category)

      case TaskCategoryModel.query_already_existing_category(name) do
        nil ->
          case TaskCategoryModel.create(params) do
            {:ok, task_category} ->
              conn
              |> put_status(200)
              |> render("task_category.json", %{task_category: task_category})

            {:error, errors} ->
              conn
              |> put_status(400)
              |> render("changeset_error.json", %{errors: errors.errors})
          end

        task_category ->
          params = %{task_category_id: task_category.id, workspace_id: workspace_id}

          case WorkspaceTaskCategoryModel.create(params) do
            {:ok, _params} ->
              conn
              |> put_status(200)
              |> render("task_category.json", %{task_category: task_category})

            {:error, errors} ->
              conn
              |> put_status(400)
              |> render("changeset_error.json", %{errors: errors.errors})
          end
      end
    else
      true ->
        conn
        |> put_status(404)
        |> json(%{"category_not_found" => true})
    end
  end

  def delete(conn, %{"workspace_id" => workspace_id, "id" => id}) do
    workspace_task_category =
      WorkspaceTaskCategoryModel.get_workspace_task_category_id(workspace_id, id)

    with false <- is_nil(workspace_task_category) do
      WorkspaceTaskCategoryModel.delete(workspace_task_category)

      conn
      |> put_status(200)
      |> json(%{"category_deleted" => true})
    else
      true ->
        conn
        |> put_status(404)
        |> json(%{"category_not_found" => true})
    end
  end

  defp load_category(%{params: %{"id" => category_id}} = conn, _params) do
    {category_id, _} = Integer.parse(category_id)

    case TaskCategoryModel.get(category_id) do
      {:ok, task_category} ->
        assign(conn, :task_category, task_category)

      {:error, _message} ->
        conn
        |> put_status(404)
    end
  end
end
