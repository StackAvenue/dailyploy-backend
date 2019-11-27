defmodule DailyployWeb.TaskCategoryController do
  use DailyployWeb, :controller
  import Plug.Conn
  alias Dailyploy.Schema.TaskCategory
  alias Dailyploy.Model.TaskCategory, as: TaskCategoryModel

  def create(conn, %{"name" => name} = attrs) do
    case TaskCategoryModel.query_already_existing_category(name) do
      nil -> 
        case TaskCategoryModel.create(attrs) do
          {:ok, _} -> 
            conn
            |> json(%{"category_created" => true})
          {:error, errors} -> 
            conn
            |> render("changeset_error.json", %{errors: errors})  
        end
       _ -> 
          conn
          |> json(%{"category_created" => true}) 
    end
  end

  def show(conn, attrs) do
    task_category = TaskCategoryModel.list_all_categories()
    render(conn, "show.json", task_category: task_category)
  end
  
end