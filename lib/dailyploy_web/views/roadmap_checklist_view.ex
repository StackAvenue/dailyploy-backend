defmodule DailyployWeb.RoadmapChecklistView do
  use DailyployWeb, :view
  alias DailyployWeb.RoadmapChecklistView

  def render("show.json", %{checklist: checklist}) do
    %{
      id: checklist.id,
      name: checklist.name,
      is_completed: checklist.is_completed
    }
  end

  def render("index_show.json", %{roadmap_checklist: checklist}) do
    %{
      id: checklist.id,
      name: checklist.name,
      is_completed: checklist.is_completed
    }
  end

  def render("user_show.json", %{roadmap_checklist: roadmap_checklist}) do
    %{
      id: roadmap_checklist.id,
      name: roadmap_checklist.name,
      is_completed: roadmap_checklist.is_completed
    }
  end

  def render("index.json", %{checklists: checklists}) do
    %{
      entries: render_many(checklists.entries, RoadmapChecklistView, "index_show.json"),
      page_number: checklists.page_number,
      page_size: checklists.page_size,
      total_entries: checklists.total_entries,
      total_pages: checklists.total_pages
    }
  end
end
