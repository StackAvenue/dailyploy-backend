defmodule DailyployWeb.UserController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Schema.User

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def index(conn, _params) do
    users = UserModel.list_users()
    render(conn, "index.json", users: users)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = UserModel.get_user!(id)

    with {:ok, %User{} = user} <- UserModel.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = UserModel.get_user!(id)

    with {:ok, %User{}} <- UserModel.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    workspace = UserModel.get_current_workspace(user)
    conn |> render("user.json", %{user: user, workspace: workspace})
  end
end
