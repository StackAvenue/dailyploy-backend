defmodule DailyployWeb.RecurringTaskView do
  use DailyployWeb, :view
  alias DailyployWeb.ErrorHelpers
  alias DailyployWeb.TaskCategoryView
  alias DailyployWeb.RecurringTaskView
  alias DailyployWeb.WorkspaceView
  alias DailyployWeb.ProjectView
  alias DailyployWeb.UserView

  def render("show.json", %{recurring_task: recurring_task}) do
    %{
      id: recurring_task.id,
      name: recurring_task.name,
      start_datetime: recurring_task.start_datetime,
      end_datetime: recurring_task.end_datetime,
      comments: recurring_task.comments,
      status: recurring_task.status,
      priority: recurring_task.priority,
      project_ids: recurring_task.project_ids,
      member_ids: recurring_task.member_ids,
      frequency: recurring_task.frequency,
      number: recurring_task.number,
      schedule: recurring_task.schedule,
      week_numbers: recurring_task.week_numbers,
      month_numbers: recurring_task.month_numbers,
      project_members_combination: recurring_task.project_members_combination,
      workspace_id: recurring_task.workspace_id,
      category_id: recurring_task.category_id,
      category: render_one(recurring_task.category, TaskCategoryView, "task_category.json"),
      workspace: render_one(recurring_task.workspace, WorkspaceView, "workspace_task.json")
      # time_tracks: render_many(TimeTrackingView, "time_tracks.json", %{time_tracking: recurring_task.time_tracks}),
      # task_comments: render_many(TaskCommentView, "comment.json", %{comment: recurring_task.task_comments})
    }
  end

  def render("index.json", %{recurring_task: recurring_task}) do
    %{
      recurring_task: render_many(recurring_task, RecurringTaskView, "show_index.json")
    }
  end

  def render("show_index.json", %{recurring_task: recurring_task}) do
    %{
      id: recurring_task.id,
      name: recurring_task.name,
      start_datetime: recurring_task.start_datetime,
      end_datetime: recurring_task.end_datetime,
      comments: recurring_task.comments,
      status: recurring_task.status,
      priority: recurring_task.priority,
      project_ids: recurring_task.project_ids,
      member_ids: recurring_task.member_ids,
      frequency: recurring_task.frequency,
      number: recurring_task.number,
      schedule: recurring_task.schedule,
      week_numbers: recurring_task.week_numbers,
      month_numbers: recurring_task.month_numbers,
      project_members_combination: recurring_task.project_members_combination,
      workspace_id: recurring_task.workspace_id,
      category_id: recurring_task.category_id,
      category: render_one(recurring_task.category, TaskCategoryView, "task_category.json"),
      projects: render_many(recurring_task.projects, ProjectView, "show_project.json"),
      members: render_many(recurring_task.members, UserView, "user_task_comments.json")
      # time_tracks: render_many(TimeTrackingView, "time_tracks.json", %{time_tracking: recurring_task.time_tracks}),
      # task_comments: render_many(TaskCommentView, "comment.json", %{comment: recurring_task.task_comments})
    }
  end
end
