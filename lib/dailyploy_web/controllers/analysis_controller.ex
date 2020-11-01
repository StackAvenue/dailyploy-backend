defmodule DailyployWeb.AnalysisController do
use DailyployWeb, :controller

alias Dailyploy.Repo
alias Dailyploy.Model.Analysis

def get_all_tasks(conn, %{"project_id" => project_id, "start_date" => start_date, "end_date" => end_date}) do
    # %{"project_id" => project_id, "start_date" => start_date,  }
      a = Analysis.get_all_tasks(project_id, start_date, end_date)
    # b = Analysis.get_all_members(project_id)
end

def get_total_time(conn,  %{"project_id" => project_id, "start_date" => start_date, "end_date" => end_date}) do
  a = Analysis.get_total_duration(project_id, start_date, end_date)
end

end
