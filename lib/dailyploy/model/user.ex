defmodule Dailyploy.Model.User do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.Role
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.Workspace
  alias Dailyploy.Schema.UserWorkspaceSetting
  alias Auth.Guardian
  import Ecto.Query
  import Comeonin.Bcrypt

  @spec list_users :: any
  def list_users() do
    Repo.all(User)
  end

  def list_users(workspace_id) do
    query =
      from(user_workspace in UserWorkspace,
        join: user in User,
        on: user_workspace.user_id == user.id,
        join: role in Role,
        on: user_workspace.role_id == role.id,
        where: user_workspace.workspace_id == ^workspace_id,
        select: %{user | role: role.name}
      )

    Repo.all(query)
  end

  def list_users(workspace_id, user_ids) do
    query =
      from(user_workspace in UserWorkspace,
        join: user in User,
        on: user_workspace.user_id == user.id,
        join: role in Role,
        on: user_workspace.role_id == role.id,
        where: user_workspace.workspace_id == ^workspace_id and user.id in ^user_ids,
        select: %{user | role: role.name}
      )

    Repo.all(query)
  end
  def list_user_workspace_setting(user_id, workspace_id) do
    from(user_workspace_setting in UserWorkspaceSetting,
      where:
        user_workspace_setting.user_id == ^user_id and
          user_workspace_setting.workspace_id == ^workspace_id
    )
    |> Repo.all()
    |> List.first()
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user!(id, preloads), do: Repo.get!(User, id) |> Repo.preload(preloads)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
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

  def get_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        Bcrypt.no_user_verify()
        {:error, "Email does not match"}

      user ->
        {:ok, user}
    end
  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    if Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end

  def get_current_workspace(user) do
    query =
      from user_workspace in UserWorkspace,
        join: workspace in Workspace,
        on: user_workspace.workspace_id == workspace.id,
        where: user_workspace.user_id == ^user.id and workspace.type == "individual"

    user_workspaces = Repo.all(query) |> Repo.preload(:workspace)
    user_workspace = List.first(user_workspaces)

    case user_workspace do
      nil -> nil
      _ -> user_workspace.workspace
    end
  end

  def get_admin_user_query do
    admin_role = Repo.get_by(Role, name: "admin")

    from user in User,
      join: userWorkspace in UserWorkspace,
      where: userWorkspace.role_id == ^admin_role.id
  end
end
