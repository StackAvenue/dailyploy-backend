defmodule DailyployWeb.WorkspaceController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.Workspace, as: WorkspaceModel

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def index(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    workspaces = WorkspaceModel.all_user_workspaces(user)
    render(conn, "index.json", workspaces: workspaces)
  end
end
