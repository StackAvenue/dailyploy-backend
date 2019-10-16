defmodule DailyployWeb.MemberController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.User, as: UserModel

  alias Dailyploy.Repo

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def index(conn, %{"workspace_id" => workspace_id}) do
    members = UserModel.list_users(workspace_id) |> Repo.preload([:projects])
    render(conn, "index_with_projects.json", members: members)
  end

end
