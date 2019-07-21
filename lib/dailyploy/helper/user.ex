defmodule Dailyploy.Helper.User do
  alias Dailyploy.Model.User, as: UserModel
  alias Ecto.Multi
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Company
  alias Auth.Guardian
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Dailyploy.Repo

  @spec create_user_with_company(%{optional(:__struct__) => none, optional(atom | binary) => any}) ::
          any
  def create_user_with_company(user_attrs) do
    case user_attrs_has_company_key?(user_attrs) do
      true ->
        %{"company" => company_data} = user_attrs
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
    (user_attrs["is_company_present"] || false) && Map.has_key?(user_attrs, "company")
  end

  defp multi_for_user_and_company_creation(user_changeset, company_changeset) do
    Multi.new()
    |> Multi.insert(:user, user_changeset)
    |> Multi.insert(:company, company_changeset)
  end



  def token_sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user)

      _ ->
        {:error, :unauthorized}
    end
  end

  defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email(email),
         do: verify_password(password, user)
  end

  defp get_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        dummy_checkpw()
        {:error, "Email does not match"}

      user ->
        {:ok, user}
    end
  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
   if checkpw(password, user.password_hash) do
      {:ok, user}
   else
     {:error, :invalid_password}
   end
  end
end

