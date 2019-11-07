defmodule DailyployWeb.RoleView do
  use DailyployWeb, :view
  alias DailyployWeb.RoleView
  alias DailyployWeb.ErrorHelpers
  
  def render("index.json", %{roles: roles}) do
    %{roles: render_many(roles, RoleView, "role.json")}
  end

  def render("role.json", %{role: role}) do
    %{
      name: role.name
    }
  end
end