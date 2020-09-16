# defmodule DailyployWeb.AllocatioController do
#   use DailyployWeb, :controller
#   import Plug.Conn

#   alias Dailyploy.Model.Allocation

#   def index(conn, %{"workspace_id" => workspace_id}) do
#     projects = Allocation.fetch_projects(workspace_id)
#     members = Allocation.fetch_members(workspace_id)

#     render(conn, "show.json", projects: projects, members: members)
#   end
# end
