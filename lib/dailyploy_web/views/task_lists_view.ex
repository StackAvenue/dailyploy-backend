defmodule DailyployWeb.TaskListsView do
  use DailyployWeb, :view
  # alias DailyployWeb.ProjectTaskListView
  alias DailyployWeb.{
    UserView,
    WorkspaceView,
    ProjectView,
    TaskListsView,
    TaskStatusView,
    TaskCategoryView,
    UserStoriesView,
    TaskListTasksView
  }

  def render("show.json", %{project_task_list: project_task_list}) do
    %{
      id: project_task_list.id,
      name: project_task_list.name,
      start_date: project_task_list.start_date,
      end_date: project_task_list.end_date,
      description: project_task_list.description,
      color_code: project_task_list.color_code,
      category: render_one(project_task_list.category, TaskCategoryView, "task_category.json"),
      workspace_id: project_task_list.workspace_id,
      status: project_task_list.status,
      creator_id: project_task_list.creator_id,
      project_id: project_task_list.project_id,
      project: render_one(project_task_list.project, ProjectView, "show_project.json"),
      workspace: render_one(project_task_list.workspace, WorkspaceView, "workspace_task.json"),
      creator: render_one(project_task_list.creator, UserView, "user.json")
    }
  end

  def render("show_project_list.json", %{task_lists: task_lists}) do
    %{
      id: task_lists.id,
      name: task_lists.name,
      start_date: task_lists.start_date,
      end_date: task_lists.end_date,
      workspace_id: task_lists.workspace_id,
      creator_id: task_lists.creator_id,
      project_id: task_lists.project_id
    }
  end

  def render("index_show.json", %{task_lists: task_lists}) do
    %{
      id: task_lists.id,
      name: task_lists.name,
      start_date: task_lists.start_date,
      end_date: task_lists.end_date,
      description: task_lists.description,
      color_code: task_lists.color_code,
      status: task_lists.status,
      workspace_id: task_lists.workspace_id,
      creator_id: task_lists.creator_id,
      project_id: task_lists.project_id,
      category: render_one(task_lists.category, TaskCategoryView, "task_category.json"),
      project: render_one(task_lists.project, ProjectView, "show_project.json"),
      workspace: render_one(task_lists.workspace, WorkspaceView, "workspace_task.json"),
      creator: render_one(task_lists.creator, UserView, "user.json"),
      user_stories: render_many(task_lists.user_stories, UserStoriesView, "task_list_view.json")
    }
  end

  def render("index.json", %{task_lists: task_lists}) do
    %{
      entries: render_many(task_lists.entries, TaskListsView, "index_show.json"),
      page_number: task_lists.page_number,
      page_size: task_lists.page_size,
      total_entries: task_lists.total_entries,
      total_pages: task_lists.total_pages
    }
  end

  def render("summary.json", %{summary: summary}) do
    %{summary: summary}
  end

  def render("show_filter.json", %{project_task_list: project_task_list}) do
    Enum.sort_by(project_task_list.task_list_tasks, & &1.updated_at)

    %{
      id: project_task_list.id,
      name: project_task_list.name,
      start_date: project_task_list.start_date,
      end_date: project_task_list.end_date,
      description: project_task_list.description,
      color_code: project_task_list.color_code,
      category: render_one(project_task_list.category, TaskCategoryView, "task_category.json"),
      workspace_id: project_task_list.workspace_id,
      status: project_task_list.status,
      creator_id: project_task_list.creator_id,
      project_id: project_task_list.project_id,
      project: render_one(project_task_list.project, ProjectView, "show_project.json"),
      workspace: render_one(project_task_list.workspace, WorkspaceView, "workspace_task.json"),
      creator: render_one(project_task_list.creator, UserView, "user.json"),
      user_stories:
        render_many(project_task_list.user_stories, UserStoriesView, "task_list_view.json"),
      task_list_tasks:
        render_many(project_task_list.task_list_tasks, TaskListTasksView, "user_show.json")
    }
  end
end
