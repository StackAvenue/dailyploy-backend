defmodule DailyployWeb.RoleController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.Role, as: RoleModel

  def index(conn, attrs) do
    roles = RoleModel.list_roles()
    render(conn, "index.json", roles: roles)
  end
end
