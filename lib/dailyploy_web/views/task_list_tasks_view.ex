defmodule DailyployWeb.TaskListTasksView do
  use DailyployWeb, :view
  # alias DailyployWeb.ProjectTaskListView
  alias DailyployWeb.{UserView, TaskListsView, TaskCategoryView}

  def render("show.json", %{task_list_tasks: task_list_tasks}) do
    %{
      id: task_list_tasks.id,
      name: task_list_tasks.name,
      description: task_list_tasks.description,
      estimation: task_list_tasks.estimation,
      status: task_list_tasks.status,
      priority: task_list_tasks.priority,
      owner_id: task_list_tasks.owner_id,
      category_id: task_list_tasks.category_id,
      task_lists_id: task_list_tasks.task_lists_id,
      owner: render_one(task_list_tasks.owner, UserView, "user.json"),
      category: render_one(task_list_tasks.category, TaskCategoryView, "task_category.json"),
      task_lists: render_one(task_list_tasks.task_lists, TaskListsView, "show_project_list.json")
    }
  end
end
