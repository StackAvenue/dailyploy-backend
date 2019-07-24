defmodule Dailyploy.Helper.User do
  alias Dailyploy.Model.User, as: UserModel
  alias Ecto.Multi
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Company
  alias Dailyploy.Repo
  alias Dailyploy.Model.Role, as: RoleModel
  alias Dailyploy.Model.Member, as: MemberModel
  alias Dailyploy.Schema.Member


  @spec create_user_with_company(%{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
  def create_user_with_company(user_attrs) do
    case user_attrs_has_company_key?(user_attrs) do
      true ->
        %{"company" => company_data} = user_attrs
        company_data = add_company_workspace(company_data)
        user_attrs = add_user_workspace(user_attrs)
        user_changeset = User.changeset(%User{}, user_attrs)
        company_changeset = Company.changeset(%Company{}, company_data)
        user_creation_result = Repo.transaction(multi_for_user_and_company_creation(user_changeset, company_changeset))
        associate_role_to_member(1, 2)
        user_creation_result

      false ->
        user_attrs = add_user_workspace(user_attrs)
        case UserModel.create_user(user_attrs) do
          {:ok, user} ->
            associate_role_to_member(1,2)
            {:ok, user}
          {:error, user} -> {:error, user}
        end
    end
  end

  defp associate_role_to_member(user_id, workspace_id) do
    member = MemberModel.get_member!(%{user_id: user_id, workspace_id: workspace_id})
    role = RoleModel.get_role_by_name(RoleModel.all_roles[:admin])
    MemberModel.update_member_role(member, role)
  end

  defp add_user_workspace(user_attrs) do
    Map.put(user_attrs, "workspaces", [%{"name" => "Workspace for #{user_attrs["name"]}", "type" => "individual"}])
  end

  defp add_company_workspace(company_attrs) do
    Map.put(company_attrs, "workspace", %{"name" => "Workspace for #{company_attrs["name"]}", "type" => "company"})
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
