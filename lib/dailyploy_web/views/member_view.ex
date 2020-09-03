defmodule DailyployWeb.MemberView do
  use DailyployWeb, :view
  alias DailyployWeb.MemberView
  alias DailyployWeb.ProjectView
  alias DailyployWeb.ErrorHelpers

  def render("index.json", %{members: members}) do
    %{members: render_many(members, MemberView, "member.json")}
  end

  def render("index_with_projects.json", %{members: members}) do
    %{members: render_many(members, MemberView, "member_with_projects.json")}
  end

  def render("show.json", %{member: member}) do
    %{member: render_one(member, MemberView, "member.json")}
  end

  def render("member.json", %{member: member}) do
    user = member.user
    role = member.role

    %{
      id: user.id,
      name: user.name,
      email: user.email,
      role: role.name
    }
  end

  def render("member_with_projects.json", %{member: member}) do
    user = member.member
    user_workspace_setting = member.user_workspace_setting || %{}

    %{
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      created_at: user.inserted_at,
      working_hours: Map.get(user_workspace_setting, :working_hours),
      hourly_expense: Map.get(user_workspace_setting, :hourly_expense),
      is_invited: false,
      projects: render_many(user.projects, ProjectView, "show_project.json")
    }
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end
end
