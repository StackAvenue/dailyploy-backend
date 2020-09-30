defmodule DailyployWeb.ProjectMemberView do
  use DailyployWeb, :view
  alias DailyployWeb.ProjectMemberView

  def render("show.json", %{project_member: project_member}) do
    %{project_member: project_member}
  end
end
