defmodule DailyployWeb.WorkspaceProjectController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Model.WorkspaceProject

  def index(conn, params) do
    projects = WorkspaceProject.get_all(params)

    render(conn, "show.json", projects: projects)
  end
end
