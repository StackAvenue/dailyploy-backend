defmodule DailyployWeb.AnalysisView do
    use DailyployWeb, :view
  
    def render("show.json", 
    %{members_count: members_count,
     task_details: task_details, 
     financial_health: financial_health, 
     bar_chart: bar_chart,
     roadmap_status: roadmap_status 
     }) do
        %{members_count: members_count, 
        task_details: task_details, 
        financial_health: financial_health, 
        bar_chart: bar_chart,
        roadmap_status: roadmap_status 
      }
    end
  
  end
  