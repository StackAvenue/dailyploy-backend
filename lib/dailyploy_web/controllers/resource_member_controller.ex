defmodule DailyployWeb.ResourceMemberController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Model.ResourceMember

  def index(conn, %{"workspace_id" => workspace_id}) do
    members = ResourceMember.fetch_members(workspace_id)

    render(conn, "show.json", members: members)
  end
end
