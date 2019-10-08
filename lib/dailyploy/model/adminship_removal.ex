defmodule Dailyploy.Model.AdminshipRemoval do
  alias Dailyploy.Repo 
  alias Dailyploy.Schema.UserWorkspace  
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Model.Role, as: RoleModel 
  alias Auth.Guardian
  import Ecto.Query

def remove_from_adminship(id, workspace_id) do
   user_workspace = UserWorkspaceModel.get_user_workspace!(%{user_id: id, workspace_id: workspace_id}, [:role])
   role = RoleModel.get_role_by_name!(RoleModel.all_roles()[:member])
   user_workspace_changeset = UserWorkspace.changeset(user_workspace, %{})  
   #Something is wrong in here need to take lifeline "Expert Advice" 
   UserWorkspaceModel.update_user_workspace_role(user_workspace_changeset, role)
end   

end