defmodule DailyployWeb.NewWorkspaceView do
  use DailyployWeb, :view

  def render("user_workspace_details.json", %{user: user, workspace: workspace}) do
    %{
      user_id: user.id,
      user_name: user.name,
      workspace_id: workspace.id,
      workspace_name: workspace.name
    }
  end
end
