defmodule Dailyploy.Model.UserWorkspaceSettings do
  alias Dailyploy.Repo
  import Ecto.Query
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.UserWorkspaceSettings
  #alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Workspace, as: WorkspaceModel
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel 
  #alias Auth.Guardian
  
  def create_user_workspace_settings(attrs \\ %{}) do
    %UserWorkspaceSettings{}
      |> UserWorkspaceSettings.changeset(attrs)
      |> Repo.insert()
  end


  def update(%{"user" => user, "workspace_id" => workspace_id} = workspace_params) do
    check_for_name_update(user, workspace_id)
    show_all_the_admins_in_current_workspace(workspace_id)
  end

  defp check_for_name_update(user,workspace_id) do
      {:ok, current_name} = Map.fetch(user,"name")
      workspace = WorkspaceModel.get_workspace!(workspace_id)
      {:ok, actual_name}  = Map.fetch(workspace, :name)
      case workspace do
        nil -> :error
        _ -> 
          with current_name !== actual_name do
            workspace_change = %{"name" => current_name}
            with  {:ok, %Workspace{} = workspace} <- WorkspaceModel.update_workspace(workspace, workspace_change) do
               workspace
            end
          end  
      end
  end

  defp show_all_the_admins_in_current_workspace(workspace_id) do
    UserWorkspaceModel.get_all_admins_using_workspace_id(workspace_id)  
  end

  def get_user_workspace_settings_id(workspace_id) do
    query = 
      from user_workspace_settings in UserWorkspaceSettings,
      where: user_workspace_settings.workspace_id == ^workspace_id

     List.first(Repo.all(query)) 
  end
  

end