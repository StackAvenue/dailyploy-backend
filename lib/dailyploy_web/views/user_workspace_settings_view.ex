defmodule DailyployWeb.UserWorkspaceSettingsView do
    use DailyployWeb, :view
    alias DailyployWeb.UserWorkspaceSettingsView
    alias DailyployWeb.ErrorHelpers

    def render("show.json", %{workspace: workspace}) do
        %{workspace_name: workspace.name, workspace_id: workspace.id}
    end
    
end