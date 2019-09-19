defmodule DailyployWeb.CompanyView do
  use DailyployWeb, :view
  alias DailyployWeb.CompanyView

  def render("show.json", %{company: company}) do
    %{company: render_one(company, CompanyView, "company.json")}
  end

  def render("company.json", %{company: company}) when company == nil, do: %{}

  def render("company.json", %{company: company}) do
    %{
      id: company.id,
      name: company.name
    }
  end

end
