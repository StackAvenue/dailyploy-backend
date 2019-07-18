defmodule DailyployWeb.UserView do
  use DailyployWeb, :view
  alias DailyployWeb.UserView
  alias DailyployWeb.ErrorHelpers

  def render("index.json", %{users: users}) do
    %{user: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{user: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      name: user.name,
      email: user.email,
     }
  end

  def render("access_token.json", %{access_token: access_token}) do
    %{access_token: access_token}
  end

  def render("signup_error.json", %{user: user}) do
    %{errors: ErrorHelpers.changeset_error_to_map(user.errors)}
  end
end
