defmodule DailyployWeb.TaskListTasksView do
  use DailyployWeb, :view
  # alias DailyployWeb.ProjectTaskListView
  alias DailyployWeb.{UserView, ProjectTaskListView, TaskCategoryView}

  def render("show.json", %{task_lists: task_lists}) do
    %{
      id: task_lists.id,
      name: task_lists.name,
      description: task_lists.description,
      estimation: task_lists.estimation,
      status: task_lists.status,
      priority: task_lists.priority,
      owner_id: task_lists.owner_id,
      category_id: task_lists.category_id,
      project_task_list_id: task_lists.project_task_list_id,
      owner: render_one(task_lists.owner, UserView, "user.json"),
      category: render_one(task_lists.category, TaskCategoryView, "task_category.json"),
      project_task_list:
        render_one(task_lists.project_task_list, ProjectTaskListView, "show_project_list.json")
    }
  end
end
