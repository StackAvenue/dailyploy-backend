defmodule DailyployWeb.ResourceController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Model.Resource

  def index(conn, %{"workspace_id" => workspace_id}) do
    projects = Resource.fetch_projects(workspace_id)
    members = Resource.fetch_members(workspace_id)

    render(conn, "show.json", projects: projects, members: members)
  end
end
