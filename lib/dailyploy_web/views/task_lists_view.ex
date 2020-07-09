defmodule DailyployWeb.TaskListsView do
  use DailyployWeb, :view
  # alias DailyployWeb.ProjectTaskListView
  alias DailyployWeb.{UserView, WorkspaceView, ProjectView}

  def render("show.json", %{project_task_list: project_task_list}) do
    %{
      id: project_task_list.id,
      name: project_task_list.name,
      start_date: project_task_list.start_date,
      end_date: project_task_list.end_date,
      description: project_task_list.description,
      color_code: project_task_list.color_code,
      workspace_id: project_task_list.workspace_id,
      creator_id: project_task_list.creator_id,
      project_id: project_task_list.project_id,
      project: render_one(project_task_list.project, ProjectView, "show_project.json"),
      workspace: render_one(project_task_list.workspace, WorkspaceView, "workspace_task.json"),
      creator: render_one(project_task_list.creator, UserView, "user.json")
    }
  end

  def render("show_project_list.json", %{project_task_list: project_task_list}) do
    %{
      id: project_task_list.id,
      name: project_task_list.name,
      start_date: project_task_list.start_date,
      end_date: project_task_list.end_date,
      workspace_id: project_task_list.workspace_id,
      creator_id: project_task_list.creator_id,
      project_id: project_task_list.project_id
    }
  end
end
