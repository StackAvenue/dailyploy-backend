defmodule DailyployWeb.ResourceAllocationController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Model.ResourceAllocation

  def index(conn, %{"workspace_id" => workspace_id}) do
    project_members = ResourceAllocation.fetch_project_members(workspace_id)

    render(conn, "show.json", project_members: project_members)
  end
end
