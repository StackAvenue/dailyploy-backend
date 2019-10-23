defmodule Dailyploy.Model.UserWorkspace do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.UserWorkspace
  alias Dailyploy.Schema.User
  import Ecto.Query

  def list_user_workspaces() do
    Repo.all(UserWorkspace)
  end

  def get_user_workspace!(%{user_id: user_id, workspace_id: workspace_id}) do
    query =
      from user_workspace in UserWorkspace,
        where: user_workspace.user_id == ^user_id and user_workspace.workspace_id == ^workspace_id

    List.first(Repo.all(query))
  end

  def get_user_workspace!(id), do: Repo.get!(UserWorkspace, id)

  def get_user_workspace!(%{user_id: user_id, workspace_id: workspace_id}, preloads) do
    query =
      from user_workspace in UserWorkspace,
        where: user_workspace.user_id == ^user_id and user_workspace.workspace_id == ^workspace_id

    user_workspace = List.first(Repo.all(query))
    Repo.preload(user_workspace, preloads)
  end

  def get_user_workspace!(id, preloads), do: Repo.get!(UserWorkspace, id) |> Repo.preload(preloads)

  def get_member_using_workspace_id(workspace_id) do
    query =
      from member in UserWorkspace,
      where: member.workspace_id == ^workspace_id and member.role_id == 1

    List.first(Repo.all(query))
  end

  def get_all_admins_using_workspace_id(workspace_id) do
    query =
      from member in UserWorkspace,
      where: member.workspace_id == ^workspace_id and member.role_id == 1

    Repo.all(query)
  end

  def get_member_using_user_id(user_id) do
    query =
      from member in UserWorkspace,
      where: member.user_id == ^user_id

    List.first(Repo.all(query))
  end

  def get_member_role(workspace_id) do
    query =
      from member in UserWorkspace,
      where: member.workspace_id == ^workspace_id

    List.first(Repo.all(query))
  end

  def user_workspaces_from_emails(workspace_id, emails) do
    query =
      from user_workspace in UserWorkspace,
      join: user in User,
      on: user_workspace.user_id == user.id,
      where: user_workspace.workspace_id == ^workspace_id and user.email in ^emails
    user_workspaces = Repo.all(query)
    user_workspaces = Repo.preload(user_workspaces, [:user])
    Enum.map(user_workspaces, fn user_workspace -> user_workspace.user end)
  end

  def create_user_workspace(attrs \\ %{}) do
    %UserWorkspace{}
    |> UserWorkspace.changeset(attrs)
    |> Repo.insert()
  end

  def update_user_workspace(%UserWorkspace{} = user_workspace, attrs) do
    user_workspace
    |> UserWorkspace.changeset(attrs)
    |> Repo.update()
  end

  def update_user_workspace_role(user_workspace, role) do
    user_workspace
    |> UserWorkspace.update_role_changeset(role)
    |> Repo.update()
  end

  #def change_user_workspace_role(user_workspace, role) do
  #  user_workspace
  #  |> put_change(:role, role)
  #  |> Repo.update()
  #end

  def delete_user_workspace(%UserWorkspace{} = user_workspace) do
    Repo.delete(user_workspace)
  end
end
