defmodule DailyployWeb.TaskStatusView do
  use DailyployWeb, :view
  alias DailyployWeb.{ProjectView, WorkspaceView, TaskStatusView}

  def render("task_status.json", %{task_status: task_status}) do
    %{
      id: task_status.id,
      name: task_status.name,
      project: render_one(task_status.project, ProjectView, "show_project.json"),
      workspace: render_one(task_status.workspace, WorkspaceView, "workspace_task.json"),
      inserted_at: task_status.inserted_at
    }
  end

  def render("index.json", task_status) do
    %{
      task_status: render_many(task_status.entries, TaskStatusView, "task_status.json"),
      page_number: task_status.page_number,
      page_size: task_status.page_size,
      total_entries: task_status.total_entries,
      total_pages: task_status.total_pages
    }
  end

  def render("status.json", %{task_status: task_status}) do
    %{
      id: task_status.id,
      name: task_status.name,
      inserted_at: task_status.inserted_at
    }
  end
end
