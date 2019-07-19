defmodule Dailyploy.Helper.User do
  alias Dailyploy.Model.User, as: UserModel
  alias Dailyploy.Model.Company, as: CompanyModel
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
        Repo.transaction multi_for_user_and_company_creation(user_changeset, company_changeset)
      false ->
        nil
    end
  end

  defp user_attrs_has_company_key?(user_attrs) do
    true
  end

  defp multi_for_user_and_company_creation(user_changeset, company_changeset) do
    Multi.new
    |> Multi.insert(:user, user_changeset)
    |> Multi.insert(:company, company_changeset)
  end
end
