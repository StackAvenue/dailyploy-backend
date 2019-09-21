defmodule DailyployWeb.TaskView do
  use DailyployWeb, :view
  alias DailyployWeb.TaskView
  alias DailyployWeb.ErrorHelpers

  def render("index.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, TaskView, "task_with_user.json")}
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
      user: render(DailyployWeb.UserView, "user.json", user: task.user)
    }
  end
  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end
end
