defmodule DailyployWeb.AnalysisView do
    use DailyployWeb, :view
  
    def render("show.json", %{members_count: members_count, task_details: task_details, financial_health: financial_health }) do
        %{members_count: members_count, task_details: task_details, financial_health: financial_health }
    end
  
  end
  