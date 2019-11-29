defmodule DailyployWeb.UserController do
  use DailyployWeb, :controller

  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Helper.User, as: UserHelper
  alias Dailyploy.Schema.User

  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def index(conn, %{"workspace_id" => workspace_id}) do
    users = UserModel.list_users(workspace_id)
    render(conn, "index.json", users: users)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"user" => user_params}) do
    case UserHelper.create_user_with_company(user_params) do
      {:ok, %User{} = user} ->
        conn
        |> put_status(:created)
        |> render("show.json", %{user: user})

      {:error, user} ->
        conn
        |> put_status(422)
        |> render("signup_error.json", %{user: user})

      {:error, _model, model_changeset, _valid_changesets} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: model_changeset.errors})

      {:ok, %{company: _company, user: user}} ->
        conn
        |> put_status(:created)
        |> render("show.json", %{user: user})
    end
  end

  def show(conn, %{"id" => id}) do
    user = UserModel.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    workspace = UserModel.get_current_workspace(user)
    conn |> render("user.json", %{user: user, workspace: workspace})
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

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case UserModel.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        conn |> render("access_token.json", access_token: token)

      _ ->
        {:error, :unauthorized}
    end
  end
end
