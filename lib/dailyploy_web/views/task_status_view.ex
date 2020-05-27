defmodule DailyployWeb.TaskStatusView do
  use DailyployWeb, :view
  # alias DailyployWeb.ProjectTaskListView
  alias DailyployWeb.{ProjectView, WorkspaceView}

  def render("task_status.json", %{task_status: task_status}) do
    %{
      id: task_status.id,
      name: task_status.name,
      project: render_one(task_status.project, ProjectView, "show_project.json"),
      workspace: render_one(task_status.workspace, WorkspaceView, "workspace_task.json")
    }
  end
end
