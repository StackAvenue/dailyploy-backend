defmodule Dailyploy.Model.AdminshipRemoval do
  alias Dailyploy.Repo 
  alias Dailyploy.Schema.UserWorkspace  
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  #alias Dailyploy.Model.Role, as: RoleModel 
  #alias Auth.Guardian
  #import Ecto.Query

def remove_from_adminship(user_workspace_attr) do
  UserWorkspaceModel.get_user_workspace!(%{user_id: user_workspace_attr["user_id"], workspace_id: user_workspace_attr["workspace_id"]})
   |> UserWorkspace.changeset(user_workspace_attr)
   |> Repo.update()  
end   

def add_for_adminship(user_workspace_attr) do
  UserWorkspaceModel.get_user_workspace!(%{user_id: user_workspace_attr["user_id"], workspace_id: user_workspace_attr["workspace_id"]})
   |> UserWorkspace.changeset(user_workspace_attr)
   |> Repo.update()  
end   


end