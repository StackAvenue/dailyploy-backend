defmodule DailyployWeb.TaskListTasksView do
  use DailyployWeb, :view
  # alias DailyployWeb.ProjectTaskListView
  alias DailyployWeb.{
    UserView,
    TaskListTasksView,
    TaskListsView,
    TaskCategoryView,
    TaskStatusView,
    RoadmapChecklistView
  }

  alias Dailyploy.Repo

  def render("show.json", %{task_list_tasks: task_list_tasks}) do
    %{
      id: task_list_tasks.id,
      name: task_list_tasks.name,
      description: task_list_tasks.description,
      task_id: task_list_tasks.task_id,
      estimation: task_list_tasks.estimation,
      status: task_list_tasks.status,
      priority: task_list_tasks.priority,
      owner_id: task_list_tasks.owner_id,
      task_status: render_one(task_list_tasks.task_status, TaskStatusView, "status.json"),
      category_id: task_list_tasks.category_id,
      task_lists_id: task_list_tasks.task_lists_id,
      comments: render_many(task_list_tasks.comments, TaskListTasksView, "comment.json"),
      owner: render_one(task_list_tasks.owner, UserView, "user.json"),
      checklist: render_many(task_list_tasks.checklist, RoadmapChecklistView, "user_show.json"),
      category: render_one(task_list_tasks.category, TaskCategoryView, "task_category.json"),
      task_lists: render_one(task_list_tasks.task_lists, TaskListsView, "show_project_list.json")
    }
  end

  def render("comment.json", %{task_list_tasks: tlt}) do
    tlt = Repo.preload(tlt, [:attachment, :user])

    %{
      comment: tlt.comments,
      attachments: tlt.attachment,
      user: tlt.user.id,
      id: tlt.id,
      user_name: tlt.user.name
    }
  end

  def render("user_show.json", %{task_list_tasks: task_list_tasks}) do
    task_list_tasks =
      task_list_tasks
      |> Dailyploy.Repo.preload([
        :owner,
        :category,
        :task_lists,
        :task_status,
        :checklist,
        :comments
      ])

    %{
      id: task_list_tasks.id,
      name: task_list_tasks.name,
      description: task_list_tasks.description,
      task_id: task_list_tasks.task_id,
      estimation: task_list_tasks.estimation,
      status: task_list_tasks.status,
      priority: task_list_tasks.priority,
      owner_id: task_list_tasks.owner_id,
      task_status: render_one(task_list_tasks.task_status, TaskStatusView, "status.json"),
      category_id: task_list_tasks.category_id,
      task_lists_id: task_list_tasks.task_lists_id,
      owner: render_one(task_list_tasks.owner, UserView, "user.json"),
      checklist: render_many(task_list_tasks.checklist, RoadmapChecklistView, "user_show.json"),
      category: render_one(task_list_tasks.category, TaskCategoryView, "task_category.json"),
      task_lists: render_one(task_list_tasks.task_lists, TaskListsView, "show_project_list.json")
    }
  end

  def render("index.json", %{task_lists: task_lists}) do
    %{
      entries: render_many(task_lists.entries, TaskListTasksView, "show.json"),
      page_number: task_lists.page_number,
      page_size: task_lists.page_size,
      total_entries: task_lists.total_entries,
      total_pages: task_lists.total_pages
    }
  end
end
