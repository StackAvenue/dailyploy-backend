defmodule DailyployWeb.TaskView do
  use DailyployWeb, :view
  alias DailyployWeb.TaskView
  alias DailyployWeb.UserView
  alias DailyployWeb.ProjectView
  alias DailyployWeb.ErrorHelpers

  def render("index.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, TaskView, "task_with_user.json")}
  end

  def render("index_with_project.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, TaskView, "task_with_project.json")}
  end

  def render("show.json", %{task: task}) do
    %{task: render_one(task, TaskView, "task_with_user.json")}
  end

  def render("task.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments
    }
  end

  def render("task_with_user.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments,
      members: render_many(task.members, UserView, "user.json"),
      owner: render_one(task.owner, UserView, "user.json")
    }
  end

  def render("task_with_project.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments,
      project: render_one(task.project, ProjectView, "project.json")
    }
  end

  def render("task_with_user_and_project.json", %{task: task}) do
    %{
      id: task.id,
      name: task.name,
      start_datetime: task.start_datetime,
      end_datetime: task.end_datetime,
      comments: task.comments,
      members: render_many(task.members, UserView, "user.json"),
      owner: render_one(task.owner, UserView, "user.json"),
      project: render_one(task.project, ProjectView, "project_for_listing.json")
    }
  end

  def render("date_formatted_user_tasks.json", %{task: {date, tasks}}) do
    %{
      date: date,
      tasks: render_many(tasks, TaskView, "task_with_project.json")
    }
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end
end
