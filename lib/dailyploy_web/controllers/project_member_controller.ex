defmodule DailyployWeb.ProjectMemberController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Model.ProjectMember

  def get_project_member(conn, %{"user_ids" => user_ids, "project_ids" => project_ids}) do
    project_member = ProjectMember.get_project_member(user_ids, project_ids)

    render(conn, "show.json", project_member: project_member)
  end
end
