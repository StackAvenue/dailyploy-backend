defmodule DailyployWeb.UserWorkspaceSettingsView do
    use DailyployWeb, :view
    alias DailyployWeb.UserWorkspaceSettingsView
    alias DailyployWeb.ErrorHelpers

    def render("show.json", %{workspace: workspace}) do
        %{workspace_id: workspace.user_id, workspace_role: workspace.role_id}
    end
    
end