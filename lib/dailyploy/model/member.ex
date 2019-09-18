defmodule Dailyploy.Model.Member do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.Member
  alias Dailyploy.Schema.User
  import Ecto.Query

  def list_members() do
    Repo.all(Member)
  end

  def get_member!(%{user_id: user_id, workspace_id: workspace_id}) do
    query =
      from member in Member,
        where: member.user_id == ^user_id and member.workspace_id == ^workspace_id

    List.first(Repo.all(query))
  end

  def get_member_using_user_id(user_id) do
    query =
      from member in Member,
      where: member.user_id == ^user_id

    List.first(Repo.all(query)) 
  end

  def get_member_role(workspace_id) do
    query =
      from member in Member,
      where: member.workspace_id == ^workspace_id

    List.first(Repo.all(query)) 
  end

  def get_member!(%{user_id: user_id, workspace_id: workspace_id}, preloads) do
    query =
      from member in Member,
        where: member.user_id == ^user_id and member.workspace_id == ^workspace_id

    member = List.first(Repo.all(query))
    Repo.preload(member, preloads)
  end

  def workspace_members_from_emails(workspace_id, emails) do
    query =
      from member in Member,
      join: user in User,
      on: member.user_id == user.id,
      where: member.workspace_id == ^workspace_id and user.email in ^emails
    members = Repo.all(query)
    members = Repo.preload(members, [:user])
    Enum.map(members, fn member -> member.user end)
  end

  def get_member!(id), do: Repo.get!(Member, id)

  def get_member!(id, preloads), do: Repo.get!(Member, id) |> Repo.preload(preloads)

  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  def update_member(%Member{} = member, attrs) do
    member
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  def update_member_role(member, role) do
    member
    |> Member.update_role_changeset(role)
    |> Repo.update()
  end

  def delete_member(%Member{} = member) do
    Repo.delete(member)
  end
end
