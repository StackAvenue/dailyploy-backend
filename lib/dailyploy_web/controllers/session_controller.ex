defmodule DailyployWeb.SessionController do
  use DailyployWeb, :controller
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Helper.User, as: UserHelper
  alias Dailyploy.Schema.User

  action_fallback DailyployWeb.FallbackController

  def sign_up(conn, %{"user" => user_params}) do
    user = UserHelper.create_user_with_company(user_params)
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

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case UserModel.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        conn |> render("access_token.json", access_token: token)

      _ ->
        {:error, :unauthorized}
    end
  end
end
