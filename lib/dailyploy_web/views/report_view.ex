defmodule DailyployWeb.ReportView do
  use DailyployWeb, :view
  alias DailyployWeb.ReportView
  alias DailyployWeb.TaskView

  def render("index.json", %{reports: reports}) do
    %{reports: render_many(reports, ReportView, "report.json")}
  end

  def render("csv_download.json", %{csv_url: csv_url}) do
    %{csv_url: csv_url}
  end

  def render("report.json", %{report: {date, tasks}}) do
    %{
      date: date,
      tasks: render_many(tasks, TaskView, "task_with_user_and_project.json")
    }
  end

  def render("project_summary_report.json", %{report_data: report_data}) do
    %{
      total_estimated_time: report_data.total_estimated_time,
      report_data: report_data.report_data
    }
  end

  def render("user_summary_report.json", %{report_data: report_data}) do
    %{
      total_estimated_time: report_data.total_estimated_time,
      total_tracked_time: report_data.total_tracked_time
    }
  end

  def render("category_summary_report.json", %{report_data: report_data}) do
    %{
      total_estimated_time: report_data.total_estimated_time,
      report_data: report_data.report_data
    }
  end

  def render("task_summary_report.json", %{report_data: report_data}) do
    %{
      total_estimated_time: report_data.total_estimated_time,
      report_data: report_data.report_data
    }
  end
end
