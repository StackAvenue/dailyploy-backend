defmodule DailyployWeb.ReportView do
  use DailyployWeb, :view
  alias DailyployWeb.ReportView
  alias DailyployWeb.TaskView

  def render("index.json", %{reports: reports}) do
    %{reports: render_many(reports, ReportView, "report.json")}
  end

  def render("report.json", %{report: {date, tasks}}) do
    %{
      date: date,
      tasks: render_many(tasks, TaskView, "task_with_user_and_project.json")
    }
  end
end
