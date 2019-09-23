defmodule DailyployWeb.MemberController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.User, as: UserModel

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def index(conn, %{"workspace_id" => workspace_id}) do
    members = UserModel.list_users(workspace_id)
    render(conn, "index.json", members: members)
  end

end
