defmodule DailyployWeb.ContactView do
  use DailyployWeb, :view
  alias DailyployWeb.ProjectView
  alias DailyployWeb.ErrorHelpers

  def render("show.json", %{contact: contact}) do
    %{
      id: contact.id,
      project_id: contact.project_id,
      name: contact.name,
      email: contact.email,
      phone_number: contact.phone_number,
      project: render_one(contact.project, ProjectView, "show_project.json")
    }
  end

  def render("changeset_error.json", %{error: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end
end
