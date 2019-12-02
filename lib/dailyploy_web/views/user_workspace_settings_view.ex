defmodule DailyployWeb.UserWorkspaceSettingsView do
  use DailyployWeb, :view
  # alias DailyployWeb.UserWorkspaceSettingsView
  alias DailyployWeb.ErrorHelpers

  def render("show.json", %{workspace: workspace}) do
    %{workspace_id: workspace.id, workspace_role: workspace.name}
  end

  def render("changeset_error.json", %{errors: errors}) do
    %{errors: ErrorHelpers.changeset_error_to_map(errors)}
  end

  def render("index.json", params) do
    %{
      id: params.id,
      user_workspace_setting_id: params.user_workspace_setting_id,
      is_active: params.is_active
    }
  end
end
