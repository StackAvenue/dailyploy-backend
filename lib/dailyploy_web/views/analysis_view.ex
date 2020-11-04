defmodule DailyployWeb.AnalysisView do
    use DailyployWeb, :view
  
    def render("show.json", 
    %{members_count: members_count,
     task_details: task_details, 
     financial_health: financial_health, 
     bar_chart: bar_chart }) do
        %{members_count: members_count, 
        task_details: task_details, 
        financial_health: financial_health, 
        bar_chart: bar_chart }
    end
  
  end
  