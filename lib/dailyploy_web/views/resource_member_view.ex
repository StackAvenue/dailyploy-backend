defmodule DailyployWeb.ResourceMemberView do
  use DailyployWeb, :view
  alias DailyployWeb.ResourceMemberView

  def render("show.json", %{members: members}) do
    %{
      members: render_many(members.entries, ResourceMemberView, "members.json"),
      page_number: members.page_number,
      page_size: members.page_size,
      total_entries: members.total_entries,
      total_pages: members.total_pages
    }
  end

  def render("members.json", %{resource_member: resource_member}) do
    user = resource_member

    %{
      id: user.id,
      name: user.name
    }
  end
end
