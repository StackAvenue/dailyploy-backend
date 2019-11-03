defmodule DailyployWeb.TokenDetailsController do
  use DailyployWeb, :controller
  import Plug.Conn
  
  alias Dailyploy.Model.Invitation, as: InvitationModel

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController
  
  def index(conn, token_id) do
    %{"name" => name, "working_hours" => working_hours, "role_id" => role_id, "project_id" => project_id, "workspace_id" => workspace_id } = InvitationModel.fetch_token_details(token_id)
    conn
    |> json(%{"name" => name, "working_hours" => working_hours, "role_id" => role_id, "project_id" => project_id, "workspace_id" => workspace_id })
  end
end