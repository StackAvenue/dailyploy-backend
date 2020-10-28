defmodule DailyployWeb.AnalysisController do
use DailyployWeb, :controller

alias Dailyploy.Repo
alias Dailyploy.Model.Analysis

def index(conn, %{"project_id" => project_id}) do
#   a = Analysis.get_all_tasks(project_id)
    b = Analysis.get_all_members(project_id)
end

end
