defmodule DailyployWeb.WorkspaceProjectView do
  use DailyployWeb, :view
  alias DailyployWeb.WorkspaceProjectView

  def render("show.json", %{projects: projects}) do
    %{
      projects: render_many(projects.entries, WorkspaceProjectView, "projects.json"),
      page_number: projects.page_number,
      page_size: projects.page_size,
      total_entries: projects.total_entries,
      total_pages: projects.total_pages
    }
  end

  def render("projects.json", %{workspace_project: workspace_project}) do
    %{
      id: workspace_project.id,
      name: workspace_project.name
    }
  end
end
