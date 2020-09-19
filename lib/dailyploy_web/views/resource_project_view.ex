defmodule DailyployWeb.ResourceProjectView do
  use DailyployWeb, :view
  alias DailyployWeb.ResourceProjectView

  def render("show.json", %{projects: projects}) do
    %{
      projects: render_many(projects.entries, ResourceProjectView, "projects.json"),
      page_number: projects.page_number,
      page_size: projects.page_size,
      total_entries: projects.total_entries,
      total_pages: projects.total_pages
    }
  end

  def render("projects.json", %{resource_project: resource_project}) do
    %{
      id: resource_project.id,
      name: resource_project.name
    }
  end
end
