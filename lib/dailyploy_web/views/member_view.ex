defmodule DailyployWeb.MemberView do
  use DailyployWeb, :view
  alias DailyployWeb.MemberView
  alias DailyployWeb.ErrorHelpers

  def render("index.json", %{members: members}) do
    %{members: render_many(members, MemberView, "member.json")}
  end

  def render("show.json", %{member: member}) do
    %{member: render_one(member, MemberView, "member.json")}
  end

  def render("member.json", %{member: member}) do
    %{id: member.id, name: member.name, email: member.email}
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end
end
