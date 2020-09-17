defmodule DailyployWeb.ResourceAllocationView do
  use DailyployWeb, :view
  alias DailyployWeb.ResourceAllocationView

  def render("show.json", %{project_members: project_members}) do
    %{
      project_members: project_members
      # projects: render_many(project_members, ResourceAllocationView, "project_members.json"),
    }
  end
end
