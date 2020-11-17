defmodule DailyployWeb.AnalysisView do
  use DailyployWeb, :view

  def render(
        "show.json",
        %{
          members_count: members_count,
          task_details: task_details,
          financial_health: financial_health,
          bar_chart: bar_chart,
          roadmap_status: roadmap_status,
          top_five_members: top_five_members
        }
      ) do
    %{
      members_count: members_count,
      task_details: task_details,
      financial_health: financial_health,
      bar_chart: bar_chart,
      roadmap_status: roadmap_status,
      top_five_members: top_five_members
    }
  end
end
