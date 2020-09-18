defmodule DailyployWeb.ResourceMemberView do
  use DailyployWeb, :view
  alias DailyployWeb.ResourceMemberView

  def render("show.json", %{members: members}) do
    %{
      members: render_many(members, ResourceMemberView, "members.json")
    }
  end

  def render("members.json", %{resource_member: resource_member}) do
    user = resource_member.member
    %{
      id: user.id,
      name: user.name
    }
  end
end
