defmodule DailyployWeb.WorkspaceMemberController do
  use DailyployWeb, :controller
  import Plug.Conn

  alias Dailyploy.Model.WorkspaceMember

  def index(conn, params) do
    members = WorkspaceMember.get_all(params)

    render(conn, "show.json", members: members)
  end
end
