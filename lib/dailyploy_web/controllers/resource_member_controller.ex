defmodule DailyployWeb.ResourceMemberController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Model.ResourceMember

  def index(conn, params) do
    # members = ResourceMember.fetch_members(workspace_id)
    members = ResourceMember.get_all(params)

    render(conn, "show.json", members: members)
  end
end
