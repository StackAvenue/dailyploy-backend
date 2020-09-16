defmodule DailyployWeb.ResourceView do
  use DailyployWeb, :view
  alias DailyployWeb.ResourceView

  def render("show.json", %{members: members, projects: projects}) do
    %{
      projects: render_many(projects, ResourceView, "projects.json"),
      members: render_many(members, ResourceView, "members.json")

    }
  end

  def render("projects.json", %{resource: resource}) do
    %{
      id: resource.id,
      name: resource.name
    }
  end

  def render("members.json", %{resource: resource}) do
    user = resource.member
    %{
      id: user.id,
      name: user.name
    }
  end
end
