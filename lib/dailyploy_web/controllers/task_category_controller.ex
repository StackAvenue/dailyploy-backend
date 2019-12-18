defmodule DailyployWeb.TaskCategoryController do
  use DailyployWeb, :controller
  import Plug.Conn
  alias Dailyploy.Schema.TaskCategory
  alias Dailyploy.Model.TaskCategory, as: TaskCategoryModel

  plug :load_category when action in [:show, :update, :delete]

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

  def create(conn, %{"name" => name} = attrs) do
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
            |> render("changeset_error.json", %{errors: errors})
        end

      _ ->
        conn
        |> json(%{"category_already_exist" => true})
    end
  end

  def index(conn, attrs) do
    task_category = TaskCategoryModel.list_all_categories()
    render(conn, "index.json", task_category: task_category)
  end

  def update(conn, params) do
    case conn.status do
      nil ->
        %{assigns: %{task_category: task_category}} = conn

        case TaskCategoryModel.update(task_category, params) do
          {:ok, task_category} ->
            conn
            |> put_status(200)
            |> render("task_category.json", %{task_category: task_category})

          {:error, errors} ->
            conn
            |> put_status(400)
            |> render("changeset_error.json", %{errors: errors})
        end

      404 ->
        conn
        |> put_status(404)
        |> json(%{"Resource Not Found" => true})
    end
  end

  def delete(conn, _params) do
    case conn.status do
      nil ->
        %{assigns: %{task_category: task_category}} = conn

        case TaskCategoryModel.delete(task_category) do
          {:ok, task_category} ->
            conn
            |> put_status(200)
            |> render("task_category.json", %{task_category: task_category})

          {:error, errors} ->
            conn
            |> put_status(400)
            |> render("changeset_error.json", %{errors: errors})
        end

      404 ->
        conn
        |> put_status(404)
        |> json(%{"Resource Not Found" => true})
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
