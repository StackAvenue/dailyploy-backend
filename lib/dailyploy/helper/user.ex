defmodule Dailyploy.Helper.User do
  alias Dailyploy.Model.User, as: UserModel
  alias Ecto.Multi
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Company

  alias Dailyploy.Repo

  def create_user_with_company(user_attrs) do
    case user_attrs_has_company_key?(user_attrs) do
      true ->
        %{company: company_data} = user_attrs
        user_changeset = User.changeset(%User{}, user_attrs)
        company_changeset = Company.changeset(%Company{}, company_data)
        Repo.transaction(multi_for_user_and_company_creation(user_changeset, company_changeset))

      false ->
        case UserModel.create_user(user_attrs) do
          {:ok, user} -> {:ok, user}
          {:error, user} -> {:error, user}
        end
    end
  end

  defp user_attrs_has_company_key?(user_attrs) do
    user_attrs[:is_company_present] && Map.has_key?(user_attrs, :company)
  end

  defp multi_for_user_and_company_creation(user_changeset, company_changeset) do
    Multi.new()
    |> Multi.insert(:user, user_changeset)
    |> Multi.insert(:company, company_changeset)
  end
end
