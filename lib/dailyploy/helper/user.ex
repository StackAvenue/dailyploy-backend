defmodule Dailyploy.Helper.User do
  alias Dailyploy.Model.User, as: UserModel
  alias Ecto.Multi
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Company
  alias Dailyploy.Repo
  alias Dailyploy.Model.Role, as: RoleModel
  alias Dailyploy.Model.UserWorkspace, as: UserWorkspaceModel
  alias Dailyploy.Schema.UserWorkspace

  @spec create_user_with_company(%{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
  def create_user_with_company(user_attrs) do
    case user_attrs_has_company_key?(user_attrs) do
      true -> create_user_when_company_data_is_present(user_attrs)
      false -> create_user_without_company(user_attrs)
    end
  end

  defp create_user_when_company_data_is_present(user_attrs) do
    %{"company" => company_data} = user_attrs
    company_data = add_company_workspace(company_data)
    user_attrs = add_user_workspace(user_attrs)
    user_changeset = User.changeset(%User{}, user_attrs)
    company_changeset = Company.changeset(%Company{}, company_data)

    user_creation_result =
      Repo.transaction(multi_for_user_and_company_creation(user_changeset, company_changeset))

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
  end

  defp associate_role_to_user_workspace(user_id, workspace_id) do
    user_workspace = UserWorkspaceModel.get_user_workspace!(%{user_id: user_id, workspace_id: workspace_id}, [:role])
    role = RoleModel.get_role_by_name!(RoleModel.all_roles()[:admin])
    user_workspace_changeset = UserWorkspace.changeset(user_workspace, %{})
    UserWorkspaceModel.update_user_workspace_role(user_workspace_changeset, role)
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

  defp multi_for_user_and_company_creation(user_changeset, company_changeset) do
    Multi.new()
    |> Multi.insert(:user, user_changeset)
    |> Multi.insert(:company, company_changeset)
  end
end
