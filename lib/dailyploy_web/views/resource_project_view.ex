defmodule DailyployWeb.ResourceProjectView do
  use DailyployWeb, :view
  alias DailyployWeb.ResourceProjectView

  def render("show.json", %{projects: projects}) do
    %{
      projects: render_many(projects, ResourceProjectView, "projects.json")
    }
  end

  def render("projects.json", %{resource_project: resource_project}) do
    %{
      id: resource_project.id,
      name: resource_project.name
    }
  end
end
