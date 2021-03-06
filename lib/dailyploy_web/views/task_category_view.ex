defmodule DailyployWeb.TaskCategoryView do
  use DailyployWeb, :view
  alias DailyployWeb.TaskCategoryView
  alias DailyployWeb.ErrorHelpers

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end

  def render("index.json", %{task_category: task_category}) do
    %{
      task_categories:
        render_many(task_category.task_categories, TaskCategoryView, "task_category.json")
    }
  end

  def render("task_category.json", %{task_category: task_category}) do
    %{
      task_category_id: task_category.id,
      name: task_category.name,
      inserted_at: task_category.inserted_at
    }
  end
end
