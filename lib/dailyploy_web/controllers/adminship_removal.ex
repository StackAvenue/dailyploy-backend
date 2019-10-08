defmodule DailyployWeb.AdminshipRemoval do
  use DailyployWeb, :controller
  import Plug.Conn
  alias Dailyploy.Model.AdminshipRemoval, as: AdminshipRemovalModel  


  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def update(conn, user_params) do
    %{"id" => user_id, "workspace_id" => workspace_id} = user_params
      case AdminshipRemovalModel.remove_from_adminship(user_id, workspace_id) do
        :error -> send_resp(conn, 401, "UNAUTHORIZED")
        workspace -> render(conn, "show.json", workspace: workspace)
      end
  end

end