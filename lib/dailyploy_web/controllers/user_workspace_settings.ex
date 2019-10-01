defmodule DailyployWeb.UserWorkspaceSettings do
  use DailyployWeb, :controller
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Workspace, as: WorkspaceModel  


  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  def update(conn, %{"id" => id, "user" => workspace_params, "workspace_id" => workspace_id}) do
       workspace = WorkspaceModel.get_workspace!(workspace_id)
       with {:ok, %Workspace{} = workspace} <- UserModel.update_workspace(workspace, workspace_params) do
        render(conn, "show.json", workspace: workspace)
       end
       
  end

end
