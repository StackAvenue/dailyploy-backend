defmodule Dailyploy.Helper.User do
  alias Ecto.Multi
  alias Dailyploy.Repo
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Company
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.Role
  alias Dailyploy.Model.Role, as: RoleModel
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Invitation, as: InvitationModel
  alias Dailyploy.Model.UserProject, as: UserProject
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Model.UserWorkspaceSettings, as: UserWorkspaceSettingsModel
  alias Dailyploy.Helper.Invitation, as: InvitationHelper
  
  
  @spec create_user_with_company(%{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
  def create_user_with_company(user_attrs) do
    case user_got_invitation?(user_attrs) do
      false ->
        case user_attrs_has_company_key?(user_attrs) do
          true -> create_user_when_company_data_is_present(user_attrs)
          false -> create_user_without_company(user_attrs)
        end
      true -> create_invited_user(user_attrs)
    end
  end

  defp create_user_when_company_data_is_present(user_attrs) do
    %{"company" => company_data} = user_attrs
    company_data = add_company_workspace(company_data)
    user_attrs = add_user_workspace(user_attrs)
    user_changeset = User.changeset(%User{}, user_attrs)
    company_changeset = Company.changeset(%Company{}, company_data)
    user_creation_result = Repo.transaction(multi_for_user_and_company_creation(user_changeset, company_changeset))
    case user_creation_result do
      {:ok, %{user: user}} -> successful_user_creation_with_company(user, user_creation_result)
      {:error, _, _, _} -> user_creation_result
    end
  end

  defp successful_user_creation_with_company(user, user_creation_result) do
    workspace = List.first(user.workspaces)
    associate_role_to_user_workspace(user.id, workspace.id)
    {:ok, %{company: company}} = user_creation_result
    company_workspace = company.workspace
    associate_company_workspace_to_user(company_workspace, user)
    user_creation_result
  end

  defp create_user_without_company(user_attrs) do
    user_attrs = add_user_workspace(user_attrs)
    case UserModel.create_user(user_attrs) do
      {:ok, user} -> successful_user_creation_without_company(user)
      {:error, user} -> {:error, user}
    end
  end

  defp successful_user_creation_without_company(user) do
    workspace = List.first(user.workspaces)
    params = %{user_id: user.id, workspace_id: workspace.id}
    UserWorkspaceSettingsModel.create_user_workspace_settings(params)
    associate_role_to_user_workspace(user.id, workspace.id)
    {:ok, user}
  end

  defp associate_company_workspace_to_user(company_workspace, user) do
    role = RoleModel.get_role_by_name!(RoleModel.all_roles()[:admin])
    UserWorkspaceModel.create_user_workspace(%{
      workspace_id: company_workspace.id,
      user_id: user.id,
      role_id: role.id
    })
    params = %{user_id: user.id, workspace_id: company_workspace.id}
    UserWorkspaceSettingsModel.create_user_workspace_settings(params)
  end

  defp associate_role_to_user_workspace(user_id, workspace_id) do
    user_workspace = UserWorkspaceModel.get_user_workspace!(%{user_id: user_id, workspace_id: workspace_id}, [:role])
    role = RoleModel.get_role_by_name!(RoleModel.all_roles()[:admin])
    user_workspace_changeset = UserWorkspace.changeset(user_workspace, %{})
    UserWorkspaceModel.update_user_workspace_role(user_workspace_changeset, role)
  end

  def add_existing_or_non_existing_user_to_member(user_id, workspace_id, project_id, working_hours) do
    %Role{id: role_id} = RoleModel.get_role_by_name!("member")
    UserWorkspaceModel.create_user_workspace(%{
      workspace_id: workspace_id,
      user_id: user_id,
      role_id: role_id
    })
    UserProject.create_user_project(%{
      user_id: user_id,
      project_id: project_id
    })
    params = %{user_id: user_id, workspace_id: workspace_id, working_hours: working_hours} #user workspace settings creation
    require IEx
    IEx.pry
    UserWorkspaceSettingsModel.create_user_workspace_settings(params) #user_workspace settings
  end

  defp add_user_workspace(user_attrs) do
    Map.put(user_attrs, "workspaces", [
      %{"name" => "Workspace for #{user_attrs["name"]}", "type" => "individual"}
    ])
  end

  defp add_company_workspace(company_attrs) do
    Map.put(company_attrs, "workspace", %{
      "name" => "Workspace for #{company_attrs["name"]}",
      "type" => "company"
    })
  end

  defp user_attrs_has_company_key?(user_attrs) do
    (user_attrs["is_company_present"] || false) && Map.has_key?(user_attrs, "company")
  end

  defp user_got_invitation?(user_attrs) do
    (user_attrs["invitation_status"] || false) && Map.has_key?(user_attrs, "invitee_details")
  end

  defp multi_for_user_and_company_creation(user_changeset, company_changeset) do
    Multi.new()
      |> Multi.insert(:user, user_changeset)
      |> Multi.insert(:company, company_changeset)
  end

  defp create_invited_user(user_attrs) do
    %{"invitee_details" => %{"token_id" => token_id}} = user_attrs
    %{"name" => name, "working_hours" => working_hours, "role_id" => role_id, "project_id" => project_id, "workspace_id" => workspace_id } = InvitationModel.fetch_token_details(token_id) #changes are done here too
    invite_attrs = %{"project_id" => project_id, "workspace_id" => workspace_id, "name" => name, "working_hours" => working_hours, "role_id" => role_id } #changes are done here need to be tested first
    %{"email" => email} = user_attrs
    user_attrs = add_user_workspace(user_attrs)
    case UserModel.create_user(user_attrs) do
      {:ok, user} ->
        successful_user_creation_without_company(user)
        %User{id: id} = user
        #ye bhi dekhna padega workspace = List.first(user.workspaces)
        add_existing_or_non_existing_user_to_member(id,workspace_id,project_id,working_hours)
        invite_attrs = Map.put(invite_attrs,"email",email)
        invite_attrs = Map.put(invite_attrs,"status", "Pending")
        invitation_details=  InvitationModel.pass_user_details(id, project_id, workspace_id)
        %UserWorkspace{id: id} = UserWorkspaceModel.get_member_using_workspace_id(workspace_id)
        %User{id: sender_id, name: sender_name} = UserModel.get_user!(id)
        invite_attrs = Map.put(invite_attrs,"sender_id",sender_id)
        invitation_details = Map.put(invitation_details,"sender_name",sender_name)
        case InvitationHelper.create_confirmation(invite_attrs, invitation_details) do
          :ok ->
            #invite_attrs = Map.replace!(invite_attrs,"status", "Active")
            {:ok, user}
          {:error, _} ->
            {:error, user}
        end
      {:error, user} -> {:error, user}
    end
  end
end
