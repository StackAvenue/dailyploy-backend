defmodule DailyployWeb.ResourceProjectController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Model.ResourceProject

  def index(conn, %{"workspace_id" => workspace_id}) do
    projects = ResourceProject.fetch_projects(workspace_id)

    render(conn, "show.json", projects: projects)
  end
end
