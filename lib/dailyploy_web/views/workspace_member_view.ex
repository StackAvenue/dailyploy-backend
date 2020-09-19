defmodule DailyployWeb.WorkspaceMemberView do
  use DailyployWeb, :view
  alias DailyployWeb.WorkspaceMemberView

  def render("show.json", %{members: members}) do
    %{
      members: render_many(members.entries, WorkspaceMemberView, "members.json"),
      page_number: members.page_number,
      page_size: members.page_size,
      total_entries: members.total_entries,
      total_pages: members.total_pages
    }
  end

  def render("members.json", %{workspace_member: workspace_member}) do
    %{
      id: workspace_member.id,
      name: workspace_member.name
    }
  end
end
