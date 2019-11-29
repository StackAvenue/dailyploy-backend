defmodule DailyployWeb.TaskCategoryView do
  use DailyployWeb, :view
  alias DailyployWeb.TaskCategoryView
  alias DailyployWeb.ErrorHelpers

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end

  def render("show.json", %{task_category: task_category}) do
    %{task_categories: render_many(task_category, TaskCategoryView, "task_category.json")}
  end

  def render("task_category.json", %{task_category: task_category}) do
    %{
      name: task_category.name
    }
  end
end
