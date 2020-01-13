defmodule DailyployWeb.WorkspaceView do
  use DailyployWeb, :view
  alias DailyployWeb.WorkspaceView
  alias DailyployWeb.UserView
  alias DailyployWeb.CompanyView
  alias DailyployWeb.ErrorHelpers

  def render("index.json", %{workspaces: workspaces}) do
    %{workspaces: render_many(workspaces, WorkspaceView, "workspace.json")}
  end

  def render("show.json", %{workspace: workspace}) do
    %{workspace: render_one(workspace, WorkspaceView, "workspace.json")}
  end

  def render("workspace.json", %{workspace: workspace}) do
    %{
      id: workspace.id,
      name: workspace.name,
      type: workspace.type,
      company: CompanyView.render("company.json", %{company: workspace.company}),
      owner: UserView.render("user.json", %{user: workspace.users |> List.first()})
    }
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end

  def render("error_message.json", %{error: error}) do
    %{errors: [error]}
  end
end
