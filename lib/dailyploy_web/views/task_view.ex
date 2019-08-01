defmodule DailyployWeb.TaskView do
  use DailyployWeb, :view
  alias DailyployWeb.TaskView
  alias DailyployWeb.ErrorHelpers


  def render("index.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, TaskView, "task.json")}
  end

  def render("show.json", %{task: task}) do
    %{task: render_one(task, TaskView, "task.json")}
  end

  def render("task.json", %{task: task}) do
    %{id: task.id, name: task.name, start_date: task.start_date, end_date: task.end_date, description: task.description, type: task.type}
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end
end

