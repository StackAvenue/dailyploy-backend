defmodule DailyployWeb.AnalysisController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Model.Analysis

  def get_analysis_details(conn, %{
        "project_id" => project_id,
        "start_date" => start_date,
        "end_date" => end_date
      }) do
    task_details = Analysis.get_all_tasks(project_id, start_date, end_date)
      members_count = Analysis.get_all_members(project_id)
      top_five_members = Analysis.get_top_5_members(project_id, start_date, end_date)
      financial_health = Analysis.get_budget(project_id, start_date, end_date)
      bar_chart = Analysis.get_weekly_data(project_id, start_date, end_date)
      roadmap_status = Analysis.get_roadmap_status(project_id, start_date, end_date)

      render(conn, "show.json",
        members_count: members_count,
        task_details: task_details,
        financial_health: financial_health,
        bar_chart: bar_chart,
        top_five_members: top_five_members,
        roadmap_status: roadmap_status
      )
  end
end
