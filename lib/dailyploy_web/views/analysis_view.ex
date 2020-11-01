defmodule DailyployWeb.AnalysisView do
    use DailyployWeb, :view
  
    def render("show.json", %{members_count: members_count, task_details: task_details }) do
        %{members_count: members_count, task_details: task_details }
    end
  
  end
  