defmodule DailyployWeb.NewWorkspaceController do
  use DailyployWeb, :controller
  alias Dailyploy.Helper.AddWorkspace
  alias Dailyploy.Model.User, as: UserModel

  plug :fetch_user_details when action in [:add_user_workspace]

  def add_user_workspace(%{params: %{"user_id" => user_id}} = conn, params) do
    case conn.status do
      404 ->
        conn
        |> put_status(404)
        |> json(%{"User Exists" => false})

      nil ->
        user = conn.assigns.user

        case AddWorkspace.create_workspace(user, params) do
          {:ok, workspace} ->
            conn
            |> put_status(200)
            |> render("user_workspace_details.json", %{user: user, workspace: workspace})

          {:error, message} ->
            conn
            |> put_status(403)
            |> json(%{"message" => message})
        end
    end
  end

  defp fetch_user_details(%{params: %{"user_id" => user_id}} = conn, _params) do
    user = UserModel.get_user(user_id)

    with false <- is_nil(user) do
      assign(conn, :user, user)
    else
      true ->
        conn
        |> put_status(404)
    end
  end
end
