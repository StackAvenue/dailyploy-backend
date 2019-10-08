defmodule DailyployWeb.UserWorkspaceSettings do
  use DailyployWeb, :controller
  import Plug.Conn
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.UserWorkspaceSettings, as: UserWorkspaceSettings  


  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def update(conn, _) do
    {:ok, params} = Map.fetch(conn, :params)
      case UserWorkspaceSettings.update(params) do
        :error -> send_resp(conn, 401, "UNAUTHORIZED")
        workspace -> render(conn, "show.json", workspace: workspace)
      end
  end

end
